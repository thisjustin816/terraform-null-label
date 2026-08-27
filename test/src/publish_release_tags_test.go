package test

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	releaseVersion   = "v2.0.0"
	releaseMovingTag = "v2.0"
)

type releaseTagTestRepository struct {
	workingDirectory string
	remoteDirectory  string
	previousCommit   string
	intendedCommit   string
}

type releaseTagInvocation struct {
	repositoryPath string
	version        string
	commitSha      string
	remoteName     string
	push           bool
	whatIf         bool
	committerDate  string
}

func TestPublishReleaseTags(t *testing.T) {
	t.Run("publishes fresh annotated tags atomically", func(t *testing.T) {
		repository := newReleaseTagTestRepository(t)
		invocation := defaultReleaseTagInvocation(repository)
		invocation.push = true
		invocation.committerDate = "2001-01-01T00:00:00Z"

		output, err := invokeReleaseTags(t, invocation)
		require.NoError(t, err, output)

		assertReleaseTag(t, repository.workingDirectory, releaseVersion, repository.intendedCommit)
		assertReleaseTag(t, repository.workingDirectory, releaseMovingTag, repository.intendedCommit)
		assertReleaseTag(t, repository.remoteDirectory, releaseVersion, repository.intendedCommit)
		assertReleaseTag(t, repository.remoteDirectory, releaseMovingTag, repository.intendedCommit)
	})

	t.Run("rerun preserves local and remote tag objects", func(t *testing.T) {
		repository := newReleaseTagTestRepository(t)
		firstInvocation := defaultReleaseTagInvocation(repository)
		firstInvocation.push = true
		firstInvocation.committerDate = "2001-01-01T00:00:00Z"

		output, err := invokeReleaseTags(t, firstInvocation)
		require.NoError(t, err, output)

		before := releaseTagObjectIDs(t, repository)
		secondInvocation := defaultReleaseTagInvocation(repository)
		secondInvocation.push = true
		secondInvocation.committerDate = "2001-01-02T00:00:00Z"

		output, err = invokeReleaseTags(t, secondInvocation)
		require.NoError(t, err, output)
		assert.Equal(t, before, releaseTagObjectIDs(t, repository))
	})

	t.Run("preserves a remote exact tag when the moving tag is missing", func(t *testing.T) {
		repository := newReleaseTagTestRepository(t)
		createAnnotatedReleaseTag(
			t,
			repository.workingDirectory,
			releaseVersion,
			repository.intendedCommit,
			"Existing exact release",
			"2001-01-01T00:00:00Z",
		)
		pushReleaseTag(t, repository.workingDirectory, releaseVersion)
		exactObjectID := releaseTagObjectID(t, repository.remoteDirectory, releaseVersion)
		runReleaseTagGit(t, repository.workingDirectory, "tag", "--delete", releaseVersion)

		invocation := defaultReleaseTagInvocation(repository)
		invocation.push = true
		invocation.committerDate = "2001-01-02T00:00:00Z"
		output, err := invokeReleaseTags(t, invocation)
		require.NoError(t, err, output)

		assert.Equal(t, exactObjectID, releaseTagObjectID(t, repository.workingDirectory, releaseVersion))
		assert.Equal(t, exactObjectID, releaseTagObjectID(t, repository.remoteDirectory, releaseVersion))
		assertReleaseTag(t, repository.remoteDirectory, releaseMovingTag, repository.intendedCommit)
	})

	t.Run("preserves a remote exact tag while replacing a stale moving tag", func(t *testing.T) {
		repository := newReleaseTagTestRepository(t)
		createAnnotatedReleaseTag(
			t,
			repository.workingDirectory,
			releaseVersion,
			repository.intendedCommit,
			"Existing exact release",
			"2001-01-01T00:00:00Z",
		)
		createAnnotatedReleaseTag(
			t,
			repository.workingDirectory,
			releaseMovingTag,
			repository.previousCommit,
			"Stale release line",
			"2001-01-01T00:00:00Z",
		)
		pushReleaseTag(t, repository.workingDirectory, releaseVersion)
		pushReleaseTag(t, repository.workingDirectory, releaseMovingTag)
		exactObjectID := releaseTagObjectID(t, repository.remoteDirectory, releaseVersion)
		staleMovingObjectID := releaseTagObjectID(t, repository.remoteDirectory, releaseMovingTag)

		invocation := defaultReleaseTagInvocation(repository)
		invocation.push = true
		invocation.committerDate = "2001-01-02T00:00:00Z"
		output, err := invokeReleaseTags(t, invocation)
		require.NoError(t, err, output)

		assert.Equal(t, exactObjectID, releaseTagObjectID(t, repository.remoteDirectory, releaseVersion))
		assert.NotEqual(t, staleMovingObjectID, releaseTagObjectID(t, repository.remoteDirectory, releaseMovingTag))
		assertReleaseTag(t, repository.remoteDirectory, releaseMovingTag, repository.intendedCommit)
	})

	t.Run("refuses a conflicting exact tag", func(t *testing.T) {
		testCases := []struct {
			name       string
			pushRemote bool
		}{
			{name: "local"},
			{name: "remote", pushRemote: true},
		}

		for _, testCase := range testCases {
			t.Run(testCase.name, func(t *testing.T) {
				repository := newReleaseTagTestRepository(t)
				createAnnotatedReleaseTag(
					t,
					repository.workingDirectory,
					releaseVersion,
					repository.previousCommit,
					"Conflicting exact release",
					"2001-01-01T00:00:00Z",
				)
				if testCase.pushRemote {
					pushReleaseTag(t, repository.workingDirectory, releaseVersion)
					runReleaseTagGit(t, repository.workingDirectory, "tag", "--delete", releaseVersion)
				}

				invocation := defaultReleaseTagInvocation(repository)
				invocation.push = true
				output, err := invokeReleaseTags(t, invocation)
				require.Error(t, err)
				assert.Contains(t, output, repository.previousCommit)
				assert.Contains(t, output, repository.intendedCommit)
				assert.False(t, releaseTagRefExists(t, repository.remoteDirectory, releaseMovingTag))
			})
		}
	})

	t.Run("atomic rejection leaves both remote refs unchanged", func(t *testing.T) {
		repository := newReleaseTagTestRepository(t)
		createAnnotatedReleaseTag(
			t,
			repository.workingDirectory,
			releaseMovingTag,
			repository.previousCommit,
			"Protected release line",
			"2001-01-01T00:00:00Z",
		)
		pushReleaseTag(t, repository.workingDirectory, releaseMovingTag)
		movingObjectID := releaseTagObjectID(t, repository.remoteDirectory, releaseMovingTag)
		runReleaseTagGit(t, repository.workingDirectory, "tag", "--delete", releaseMovingTag)

		// Disabling atomic advertisement only tests capability detection, while hideRefs is rejected
		// before the ref transaction. A stale lock makes the advertised atomic transaction fail.
		movingLockPath := filepath.Join(
			repository.remoteDirectory,
			"refs",
			"tags",
			releaseMovingTag+".lock",
		)
		require.NoError(t, os.WriteFile(movingLockPath, []byte("test lock\n"), 0o644))
		t.Cleanup(func() {
			err := os.Remove(movingLockPath)
			if err != nil && !errors.Is(err, os.ErrNotExist) {
				t.Errorf("remove temporary moving-tag lock: %v", err)
			}
		})

		invocation := defaultReleaseTagInvocation(repository)
		invocation.push = true
		output, err := invokeReleaseTags(t, invocation)
		require.Error(t, err, output)
		assert.False(t, releaseTagRefExists(t, repository.remoteDirectory, releaseVersion), output)
		assert.Equal(
			t,
			movingObjectID,
			releaseTagObjectID(t, repository.remoteDirectory, releaseMovingTag),
			output,
		)
	})

	t.Run("validates repository version commit and remote", func(t *testing.T) {
		repository := newReleaseTagTestRepository(t)
		subdirectory := filepath.Join(repository.workingDirectory, "nested")
		require.NoError(t, os.MkdirAll(subdirectory, 0o755))

		testCases := []struct {
			name        string
			mutate      func(*releaseTagInvocation)
			wantMessage string
		}{
			{
				name: "missing repository",
				mutate: func(invocation *releaseTagInvocation) {
					invocation.repositoryPath = filepath.Join(t.TempDir(), "missing")
				},
				wantMessage: "RepositoryPath",
			},
			{
				name: "repository subdirectory",
				mutate: func(invocation *releaseTagInvocation) {
					invocation.repositoryPath = subdirectory
				},
				wantMessage: "Git root",
			},
			{
				name: "invalid exact version",
				mutate: func(invocation *releaseTagInvocation) {
					invocation.version = "2.0.0"
				},
				wantMessage: "Version",
			},
			{
				name: "unknown commit",
				mutate: func(invocation *releaseTagInvocation) {
					invocation.commitSha = strings.Repeat("f", 40)
				},
				wantMessage: "commit",
			},
			{
				name: "missing remote",
				mutate: func(invocation *releaseTagInvocation) {
					invocation.remoteName = "missing"
				},
				wantMessage: "remote",
			},
		}

		for _, testCase := range testCases {
			t.Run(testCase.name, func(t *testing.T) {
				invocation := defaultReleaseTagInvocation(repository)
				testCase.mutate(&invocation)
				output, err := invokeReleaseTags(t, invocation)
				require.Error(t, err)
				assert.Contains(t, strings.ToLower(output), strings.ToLower(testCase.wantMessage))
			})
		}
	})

	t.Run("WhatIf does not create local or remote refs", func(t *testing.T) {
		repository := newReleaseTagTestRepository(t)
		invocation := defaultReleaseTagInvocation(repository)
		invocation.push = true
		invocation.whatIf = true

		output, err := invokeReleaseTags(t, invocation)
		require.NoError(t, err, output)
		assert.False(t, releaseTagRefExists(t, repository.workingDirectory, releaseVersion))
		assert.False(t, releaseTagRefExists(t, repository.workingDirectory, releaseMovingTag))
		assert.False(t, releaseTagRefExists(t, repository.remoteDirectory, releaseVersion))
		assert.False(t, releaseTagRefExists(t, repository.remoteDirectory, releaseMovingTag))
	})
}

func newReleaseTagTestRepository(t testing.TB) releaseTagTestRepository {
	t.Helper()

	testDirectory := t.TempDir()
	workingDirectory := filepath.Join(testDirectory, "working repository")
	remoteDirectory := filepath.Join(testDirectory, "remote repository.git")
	runReleaseTagGit(t, testDirectory, "init", "--bare", remoteDirectory)
	runReleaseTagGit(t, testDirectory, "init", "--initial-branch=main", workingDirectory)
	runReleaseTagGit(t, workingDirectory, "config", "user.name", "Release Tag Test")
	runReleaseTagGit(t, workingDirectory, "config", "user.email", "release-tag-test@example.com")
	runReleaseTagGit(t, workingDirectory, "config", "commit.gpgSign", "false")
	runReleaseTagGit(t, workingDirectory, "config", "tag.gpgSign", "false")

	trackedFile := filepath.Join(workingDirectory, "content.txt")
	require.NoError(t, os.WriteFile(trackedFile, []byte("first\n"), 0o644))
	runReleaseTagGit(t, workingDirectory, "add", "content.txt")
	runReleaseTagGit(t, workingDirectory, "commit", "--message", "First test commit")
	previousCommit := runReleaseTagGit(t, workingDirectory, "rev-parse", "HEAD")

	require.NoError(t, os.WriteFile(trackedFile, []byte("second\n"), 0o644))
	runReleaseTagGit(t, workingDirectory, "add", "content.txt")
	runReleaseTagGit(t, workingDirectory, "commit", "--message", "Second test commit")
	intendedCommit := runReleaseTagGit(t, workingDirectory, "rev-parse", "HEAD")
	runReleaseTagGit(t, workingDirectory, "remote", "add", "origin", remoteDirectory)
	runReleaseTagGit(t, workingDirectory, "push", "--set-upstream", "origin", "main")

	return releaseTagTestRepository{
		workingDirectory: workingDirectory,
		remoteDirectory:  remoteDirectory,
		previousCommit:   previousCommit,
		intendedCommit:   intendedCommit,
	}
}

func defaultReleaseTagInvocation(repository releaseTagTestRepository) releaseTagInvocation {
	return releaseTagInvocation{
		repositoryPath: repository.workingDirectory,
		version:        releaseVersion,
		commitSha:      repository.intendedCommit,
		remoteName:     "origin",
	}
}

func invokeReleaseTags(t testing.TB, invocation releaseTagInvocation) (string, error) {
	t.Helper()

	pwshPath, err := exec.LookPath("pwsh")
	require.NoError(t, err, "pwsh is required for release tag tests")
	scriptPath := filepath.Join(repositoryRoot(t), "scripts", "Publish-ReleaseTags.ps1")
	arguments := []string{
		"-NoLogo",
		"-NoProfile",
		"-NonInteractive",
		"-File",
		scriptPath,
		"-RepositoryPath",
		invocation.repositoryPath,
		"-Version",
		invocation.version,
		"-CommitSha",
		invocation.commitSha,
		"-RemoteName",
		invocation.remoteName,
	}
	if invocation.push {
		arguments = append(arguments, "-Push")
	}
	if invocation.whatIf {
		arguments = append(arguments, "-WhatIf")
	}

	command := exec.Command(pwshPath, arguments...)
	command.Env = append(os.Environ(), "GIT_TERMINAL_PROMPT=0")
	if invocation.committerDate != "" {
		command.Env = append(command.Env, "GIT_COMMITTER_DATE="+invocation.committerDate)
	}
	output, err := command.CombinedOutput()

	return string(output), err
}

func createAnnotatedReleaseTag(
	t testing.TB,
	repositoryPath string,
	tagName string,
	commitSha string,
	message string,
	committerDate string,
) {
	t.Helper()

	runReleaseTagGitWithEnvironment(
		t,
		repositoryPath,
		[]string{"GIT_COMMITTER_DATE=" + committerDate},
		"tag",
		"--force",
		"--annotate",
		tagName,
		commitSha,
		"--message",
		message,
	)
}

func pushReleaseTag(t testing.TB, repositoryPath string, tagName string) {
	t.Helper()

	runReleaseTagGit(
		t,
		repositoryPath,
		"push",
		"origin",
		"refs/tags/"+tagName+":refs/tags/"+tagName,
	)
}

func assertReleaseTag(t testing.TB, repositoryPath string, tagName string, commitSha string) {
	t.Helper()

	assert.Equal(t, "tag", runReleaseTagGit(t, repositoryPath, "cat-file", "-t", "refs/tags/"+tagName))
	assert.Equal(
		t,
		commitSha,
		runReleaseTagGit(t, repositoryPath, "rev-parse", "refs/tags/"+tagName+"^{commit}"),
	)
}

func releaseTagObjectIDs(t testing.TB, repository releaseTagTestRepository) map[string]string {
	t.Helper()

	return map[string]string{
		"local exact":   releaseTagObjectID(t, repository.workingDirectory, releaseVersion),
		"local moving":  releaseTagObjectID(t, repository.workingDirectory, releaseMovingTag),
		"remote exact":  releaseTagObjectID(t, repository.remoteDirectory, releaseVersion),
		"remote moving": releaseTagObjectID(t, repository.remoteDirectory, releaseMovingTag),
	}
}

func releaseTagObjectID(t testing.TB, repositoryPath string, tagName string) string {
	t.Helper()

	return runReleaseTagGit(t, repositoryPath, "rev-parse", "refs/tags/"+tagName)
}

func releaseTagRefExists(t testing.TB, repositoryPath string, tagName string) bool {
	t.Helper()

	_, err := runReleaseTagGitE(
		repositoryPath,
		nil,
		"show-ref",
		"--verify",
		"--quiet",
		"refs/tags/"+tagName,
	)
	if err == nil {
		return true
	}

	var exitError *exec.ExitError
	require.True(t, errors.As(err, &exitError), "unexpected git error: %v", err)
	require.Equal(t, 1, exitError.ExitCode(), "unexpected git exit code")

	return false
}

func runReleaseTagGit(t testing.TB, repositoryPath string, arguments ...string) string {
	t.Helper()

	return runReleaseTagGitWithEnvironment(t, repositoryPath, nil, arguments...)
}

func runReleaseTagGitWithEnvironment(
	t testing.TB,
	repositoryPath string,
	environment []string,
	arguments ...string,
) string {
	t.Helper()

	output, err := runReleaseTagGitE(repositoryPath, environment, arguments...)
	require.NoError(t, err, "git %s failed: %s", strings.Join(arguments, " "), output)

	return strings.TrimSpace(output)
}

func runReleaseTagGitE(repositoryPath string, environment []string, arguments ...string) (string, error) {
	commandArguments := append([]string{"-C", repositoryPath}, arguments...)
	command := exec.Command("git", commandArguments...)
	command.Env = append(os.Environ(), "GIT_TERMINAL_PROMPT=0")
	command.Env = append(command.Env, environment...)
	output, err := command.CombinedOutput()
	if err != nil {
		err = fmt.Errorf("git %s: %w", strings.Join(arguments, " "), err)
	}

	return string(output), err
}
