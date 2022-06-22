# Sym API Orb 


[![CircleCI Build Status](https://circleci.com/gh/symopsio/sym-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/symopsio/sym-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/sym/sym-orb.svg)](https://circleci.com/orbs/registry/orb/sym/sym-orb) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/symopsio/sym-orb/main/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

Send Sym API requests from your CircleCI pipelines.

[What are Orbs?](https://circleci.com/orbs/)

## Usage
### Setup
In order to use the Sym API Orb on CircleCI you will need to create a `SYM_JWT` and set it as an environment variable
available for use in your pipeline.

1. Create a Bot user with `symflow bots create [bot-name]`
2. Issue a `SYM_JWT` with `symflow tokens issue -u [bot-name] -e [expiry-length]`
3. Save the JWT outputted by this previous step into an environment variable available to your workflow. You can do this by [adding the variable to a CircleCI Context](https://circleci.com/docs/2.0/env-vars#setting-an-environment-variable-in-a-context),
or by [adding it to the Project Settings](https://circleci.com/docs/2.0/env-vars#setting-an-environment-variable-in-a-project)

For more detailed documentation about Sym Bots and Tokens, visit the Sym Docs: [Bot Users and Tokens](https://docs.symops.com/docs/using-bot-tokens).

---

## Resources
- [CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/sym/sym-orb) - The official registry page of this orb for all versions, executors, commands, and jobs described.
- [Sym Documentation](https://docs.symops.com/docs) - The official docs page for Sym

### How to Contribute

We welcome [issues](https://github.com/symopsio/sym-orb/issues) to and [pull requests](https://github.com/symopsio/sym-orb/pulls) against this repository!

### How to Publish An Update
1. Merge pull requests with desired changes to the main branch.
    - For the best experience, squash-and-merge and use [Conventional Commit Messages](https://conventionalcommits.org/).
2. Find the current version of the orb.
    - You can run `circleci orb info sym/sym | grep "Latest"` to see the current version.
3. Create a [new Release](https://github.com/symopsio/sym-orb/releases/new) on GitHub.
    - Click "Choose a tag" and _create_ a new [semantically versioned](http://semver.org/) tag. (ex: v1.0.0)
      - We will have an opportunity to change this before we publish if needed after the next step.
4.  Click _"+ Auto-generate release notes"_.
    - This will create a summary of all of the merged pull requests since the previous release.
    - If you have used _[Conventional Commit Messages](https://conventionalcommits.org/)_ it will be easy to determine what types of changes were made, allowing you to ensure the correct version tag is being published.
5. Now ensure the version tag selected is semantically accurate based on the changes included.
6. Click _"Publish Release"_.
    - This will push a new tag and trigger your publishing pipeline on CircleCI.
