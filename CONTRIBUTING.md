# Contributing
`konfig` uses GitHub to manage reviews of pull requests.

* If you have a trivial fix or improvement, go ahead and create a pull request.

* Code must be properly formatted

## Building & Testing

This repository uses [bats](https://github.com/sstephenson/bats) for testing.
To run the tests, install `bats`, then
```bash
make test
```

## Pull Request Checklist

* Add a [DCO](https://developercertificate.org/) / `Signed-off-by` line in any commit message (`git commit --signoff`).

* Branch from master and, if needed, rebase to the current master branch before submitting your pull request.
  If it doesn't merge cleanly with master you will be asked to rebase your changes.

* Commits should be small units of work with one topic. Each commit should be correct independently.

* Add tests relevant to the fixed bug or new feature.

## Releases

This is a checklist for new releases:

0. Create release notes in `doc/releases`
0. Update usage instructions, if applicable
0. Create a new tag via `hack/make_tag.sh`
0. Push the tag to GitHub `git push --tags`
0. Create new release on GitHub Releases and upload artifacts
0. Update [krew-index](https://github.com/GoogleContainerTools/krew-index)
