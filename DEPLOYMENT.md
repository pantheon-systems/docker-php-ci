---
contract_version: 2
kind: tool                          # public CI image; other repos' CI pulls it by floating tag
service: php-ci

trigger: merge-to-main              # a Quay build trigger builds EVERY pushed branch into a tag named after the branch; the default branch (4.x) also gets `latest`
merged_implies_deployed: true       # tags are floating: the next CI pull gets the new image (if the Quay build runs; see pipeline.current_state)
other_paths_to_prod:
  - "a push to ANY branch builds and pushes a tag of the same name (e.g. v8.2, v7.4, 1.x); v8.2 is the tag Terminus's release workflow runs in"
  - "re-running a Quay build of an old commit republishes that tag with today's upstream packages (the build isn't reproducible: unpinned apk and base images)"

pipeline:
  system: other                     # Quay build trigger on GitHub push; there are no GitHub Actions workflows
  workflow: "Quay build trigger for quay.io/pantheon-public/php-ci (Dockerfile at repo root, context /)"
  jobs_in_order: ["quay build", "push tag <branch> (+ latest for 4.x)"]
  typical_minutes: 2                # inferred from Quay build start (19:56:00) to tag last_modified (19:57:34), 94a79e7 on 2024-09-23
  minutes_by_change: {}
  watch: "https://quay.io/api/v1/repository/pantheon-public/php-ci/build/?limit=5 (public): phase `complete` for your commit"
  concurrency_group: null
  cancel_in_progress: false
  blocked_by_waiting_run: null
  approval_gate: null
  current_state: "TODO(verify-on-deploy): the last Quay build (2026-02-23, DELENG-365 branch) is `expired` (never ran), the [skip ci] commits on 4.x since 2026-09-24 started no build, and pushing branch docs/DEVX-7892-deploy-contract (90cc0cf, 2026-11-10) started none within ~90 s. The trigger is probably dead; confirm on the next real merge"   # verified from the Quay build list 2026-11-10

repo_properties:
  observed_at: 2026-11-10
  trust_level: TL3
  ccb_status: in-ccb
  owner: developer-experience
  repo_type: tool

gating_checks:                      # for 4.x (default branch)
  required: ["Wiz IaC Scanner", "Wiz Vulnerability Scanner", "Wiz Data Scanner"]   # org TL3 only
  approvals: {required: 1, code_owner: true, last_push_approval: false, strict_up_to_date: true, merge_queue: false}
  run_but_not_required: []          # no CI besides the Quay build
  conditional: []
  code_owners: "@pantheon-systems/developer-experience"

environments: []

artifact:
  image: quay.io/pantheon-public/php-ci
  tag_scheme: fixed                 # tag = branch name; 4.x also tagged latest
  tag_mutable: true
  retention: "Quay keeps a tag's previous manifest for 14 days (tag_expiration_s 1209600)"   # verified from the repository API
  version_signal: digest
  current:                          # verified 2026-11-10 via the public Quay API
    "4.x / latest": "sha256:82a317e19502d7a31f327aacbeb1a3850077f3814be5b795c6d48ded523069d2 (2024-09-23, 94a79e7)"
    "v8.2": "sha256:58b7be780fb1e0bba5a40c12ee4937e5e7da778065b30d2f5113c3445a83967f (2023-10-23)"
    "v7.4": "sha256:ab41dc2d0ffb8b9d67cf1d3bc171757da8a71ccb11be5b4bffe2aa815383bc6e (2021-06-23)"
    "1.x": "2019-03-28; manifest schema 1, which current Docker refuses to pull"

release:
  mechanism: "push to a branch; Quay builds and pushes the tag of the same name"
  never: "push to v8.2 without checking Terminus: its release workflow builds the phar and publishes releases inside php-ci:v8.2"

consumers:                          # all pull a floating tag at CI run time
  - {repo: terminus, pin: ".github/workflows/4.x.yml jobs checkout_build and release: php-ci:v8.2"}
  - {repo: terminus-build-tools-plugin, pin: ".circleci/config.yml: php-ci:v8.2"}
  - {repo: terminus-composer-logs-plugin, pin: ".github/workflows/ci.yml: php-ci:v8.2"}
  - {repo: terminus-scheduled-jobs-plugin-private, pin: ".github/workflows/ci.yml: php-ci:v7.4"}
  - {repo: tbt-ci-templates, pin: "d8 GitHub Actions template: php-ci:4.x"}
  - {repo: php-site-repository-tool, pin: ".github/workflows/ci.yml release job: php-ci:1.x (fails to pull: schema 1 manifest)"}
  - {repo: "customer CI built from the tbt-ci-templates d8 template", pin: "php-ci:4.x [inferred]"}

deployed_when:
  - "Quay build for the pushed commit is `complete`"
  - "the tag's manifest_digest changed and last_modified is after the push"

health:
  soak_minutes: null                # delegated to consumers' CI
  baseline: null
  checks:
    - name: tag digest moved
      kind: command
      run: "curl -s 'https://quay.io/api/v1/repository/pantheon-public/php-ci/tag/?specificTag=<tag>&onlyActiveTags=true' | jq -r '.tags[0]|[.last_modified,.manifest_digest]|@tsv'"
      healthy: "new digest after the push"
    - name: consumer CI
      kind: delegate
      run: "the next Terminus 4.x CI run (for v8.2) or the consumer that uses the changed tag"
      healthy: "no new failures in steps that run inside the image"
  known_baseline_errors: ["php-ci:1.x can't be pulled (schema 1 manifest); php-site-repository-tool's tag release job fails on it"]
  dashboards: []
  alerts: []

rollback:
  options:
    - when: "within 14 days of a bad push"
      kind: redeploy-previous
      steps: "in Quay, restore the tag to its previous manifest (tag history). TODO(owner): who has write/admin on the pantheon-public Quay org"
      time_to_rollback_minutes: 10  # inferred
    - when: otherwise
      kind: revert-and-merge
      steps: "revert on the branch and let Quay rebuild. Doesn't reproduce the old image (unpinned base image and apk packages), and depends on the trigger still working"
      time_to_rollback_minutes: null
  not_restored: []
  one_way_changes: []
  currently_blocked: null
  last_exercised: null
  capture_before_merge: "the tag-digest command above for the branch's tag (and latest for 4.x); record manifest_digest"
  who_can: ["TODO(owner): Quay pantheon-public org members with write"]
  verify: "the tag's digest equals the captured one"

escalation:
  slack: "#ask-hosting"
  owner_team: developer-experience
  paged: false
  known_security_issue: "TODO(owner): ticket"

preflight:
  - "gh auth status"
  - "outbound HTTPS to quay.io (public reads, no auth)"

automation_blockers:
  - blocker: "floating tags only: any branch push is an immediate change for every consumer of that tag (including Terminus releases), with no per-build tag to roll back to"
    clears_when: "builds also push an immutable per-commit tag and important consumers (terminus) pin it"
  - blocker: "builds aren't reproducible, and it's unknown whether the Quay trigger still runs"
    clears_when: "the next real merge shows a `complete` Quay build, or builds move to GitHub Actions with pinned inputs"
  - blocker: "digest rollback needs Quay access nobody has written down"
    clears_when: "TODO(owner) names the holders"

verified:
  at: null
  by: null
  change: null
  running_digest: null
---

# Deployment

`docker-php-ci` is the Dockerfile for the public CI image `quay.io/pantheon-public/php-ci`. There is no GitHub Actions pipeline: **a Quay build trigger builds every pushed branch into a tag of the same name**, and the default branch `4.x` also becomes `latest`. Tags are floating, so consumers get a new image on their next CI run.

## How a change reaches production

1. Merge to `4.x` (one code-owner approval, org TL3), or push to another branch. Quay builds the root `Dockerfile` and pushes `<branch>` (plus `latest` for `4.x`). The last `4.x` build took about 2 minutes (2024-09-23, `94a79e7`) [inferred from build start and tag time].
2. Consumers pull the tag on their next CI run.

Each branch is effectively a separate product:

| Tag | Built from | Last pushed | Used by |
| --- | --- | --- | --- |
| `v8.2` | branch `v8.2` (`php:8.2-cli`) | 2023-10-23 | **terminus** `4.x.yml` (`checkout_build` and `release` jobs, i.e. Terminus releases are built in it), terminus-build-tools-plugin, terminus-composer-logs-plugin |
| `4.x` / `latest` | branch `4.x` (`drupaldocker/php:7.3-cli-2.x`) | 2024-09-23 | tbt-ci-templates d8 GitHub Actions template |
| `v7.4` | branch `v7.4` | 2021-06-23 | terminus-scheduled-jobs-plugin-private |
| `1.x` | branch `1.x` | 2019-03-28 | php-site-repository-tool's release job, which fails: the image has a schema 1 manifest that current Docker won't pull |

Feature branches get tags too (e.g. `lops-1850`, `add-catalog-info-20240910`).

**Is the trigger still alive?** TODO(verify-on-deploy): the last Quay build (2026-02-23, a feature branch) shows `expired` (it never ran), the github-terraform `[skip ci]` commits on `4.x` since 2026-09-24 started no build, and pushing this contract's branch (`90cc0cf`, 2026-11-10) started none within about 90 seconds. It's probably dead; check the Quay build list after the next real merge.

## How to confirm it deployed

```bash
curl -s 'https://quay.io/api/v1/repository/pantheon-public/php-ci/build/?limit=5' \
  | jq -r '.builds[]|[.started,.phase,.display_name,(.tags|join(","))]|@tsv'
curl -s 'https://quay.io/api/v1/repository/pantheon-public/php-ci/tag/?specificTag=4.x&onlyActiveTags=true' \
  | jq -r '.tags[0]|[.last_modified,.manifest_digest]|@tsv'
```

The build for your commit (`display_name` = short sha) should be `complete`, and the tag's digest should be new. On 2026-11-10, `4.x`/`latest` were `sha256:82a317e1…` (2024-09-23).

## How to confirm it's healthy

Delegated to consumers: the next CI run that uses the changed tag (for `v8.2`, a Terminus `4.x` run) should show no new failures in steps inside the image. No dashboards or alerts exist.

## Rollback

Capture the tag's digest before merging (the tag command above).

1. **Within 14 days:** restore the tag to its previous manifest in Quay (tag history is kept 14 days). TODO(owner): who has write on the Quay `pantheon-public` org.
2. **Otherwise:** revert and let Quay rebuild. That doesn't reproduce the old image (unpinned base image and packages) and needs the trigger to work.

Rollback has never been exercised. Verify that the tag's digest equals the captured one.

## Escalation

`#ask-hosting` (developer-experience). Nobody is paged.

## Suggested pipeline changes

- Move builds to GitHub Actions (or confirm the Quay trigger works), and push an immutable per-commit tag alongside each floating one.
- Have Terminus pin `php-ci` by digest or per-commit tag for its release jobs.
- Rebuild or delete `1.x` (schema 1, unpullable) and move php-site-repository-tool's release job off it.
- Delete stale branch tags (feature branches, `master`, `terminus-1.8.0`).
- Known security issue: TODO(owner): ticket.
