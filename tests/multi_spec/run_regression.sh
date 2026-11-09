#!/bin/sh
# Same-seed comparison of the single-specification aristeo on master and on
# the current working tree. Usage: tests/multi_spec/run_regression.sh [--pendulum]
# Temporary files go to $WORKDIR (default: /tmp). Do not point TMPDIR to a long
# path: MATLAB then fails to start.
set -e
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../.." && pwd)
work=$(mktemp -d "${WORKDIR:-/tmp}/aristeo_regression.XXXXXX")
trap 'rm -rf "$work"' EXIT
pend=false
[ "$1" = "--pendulum" ] && pend=true
git -C "$repo" archive master ARIsTEO | tar -x -C "$work"
cd "$here"
matlab -batch "regression_single_spec('run', '$work/ARIsTEO', '$work/master.mat', $pend)"
matlab -batch "regression_single_spec('run', '$repo/ARIsTEO', '$work/branch.mat', $pend)"
matlab -batch "regression_single_spec('compare', '$work/master.mat', '$work/branch.mat')"
