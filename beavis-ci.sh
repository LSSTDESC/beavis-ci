#! /usr/bin/env bash
#=======================================================================
#+
# NAME:
#   beavis-ci.sh
#
# PURPOSE:
#   Enable occasional integration and testing. Like travis-ci but dumber.
#
# COMMENTS:
#   Makes "rendered" versions of all the notebooks listed in a folder
#   and deploys them to a "rendered" orphan branch, pushed to GitHub
#   for web display.
#
# INPUTS:
#   repo          The name of a repo to test, eg LSSTDESC/DC2-analysis
#
# OPTIONAL INPUTS:
#   -h --help        Print this header
#   -b --branch      Test the notebooks in a dev branch. Default is "master". Outputs will go to "rendered-$branch"
#   -k --kernel      Enforce a specific kernel
#   -n --notebooks   Run on notebooks that match this. Default is '*'
#   -w --working-dir Working directory. Default is '.beavis'
#   -j --jupyter     Full path to jupyter executable
#   --no-commit      Only run the notebooks, do not commit any output
#   --push           Force push the results to the "rendered" branch. Only work if you have push permission
#   --html           Make html outputs instead
#
# OUTPUTS:
#
# EXAMPLES:
#   ./beavis-ci.sh LSSTDESC/DC2-analysis
#
# LICENSE:
# BSD 3-Clause License
#
# Copyright (c) 2018, LSST Dark Energy Science Collaboration (DESC)
# beavis-ci contributors.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#-
# ======================================================================

help=0
commit=1
push=0
html=0
src="$0"
branch='master'
output_branch_default='rendered'
notebook_name='*'
working_dir='.beavis'
jupyter=$( command -v jupyter || echo '/usr/common/software/python/3.6-anaconda-4.4/bin/jupyter' )

while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -h|--help)
            help=1
            ;;
        --no-commit)
            commit=0
            ;;
        --push)
            push=1
            ;;
        --html)
            html=1
            ;;
        -b|--branch)
            shift
            branch="$1"
            ;;
        -j|--jupyter)
            shift
            jupyter="$1"
            ;;
        -k|--kernel)
            shift
            kernel="$1"
            ;;
        -n|--notebooks)
            shift
            notebook_name="$1"
            ;;
        -w|--working-dir)
            shift
            working_dir="$1"
            ;;
        *)
            repo="$1"
            ;;
    esac
    shift
done

if [ $help -gt 0 ] || [ -z $repo ]; then
    more $src
    exit 1
fi

date
original_pwd=`pwd`
echo "Welcome to beavis-ci: occasional integration and testing"
echo "Cloning ${repo}/${branch} into the ${working_dir} workspace:"

# Check out a fresh clone in a temporary hidden folder, over-writing
# any previous edition:
mkdir -p ${working_dir}
cd ${working_dir}
repo_dir=`basename $repo`
rm -rf ${repo_dir}
git clone -b ${branch} git@github.com:${repo}.git
if [ -e $repo_dir ]; then
    cd $repo_dir
    repo_full_path=`pwd`
else
    echo "Failed to clone ${repo}/${branch}! Abort!"
    exit 1
fi

# set target output branch
target="${output_branch_default}"
if [ "$branch" != "master" ]; then
    target="${target}-${branch}"
fi

# set html or notebook option
if [ $html -gt 0 ]; then
    echo "Making static HTML pages..."
    outputformat="HTML"
    ext="html"
    target="${target}-html"
else
    echo "Rendering notebooks..."
    outputformat="notebook"
    ext="nbconvert.ipynb"
fi

# set kernel option
if [ -z $kernel ]; then
    kernel_option=""
else
    kernel_option="--ExecutePreprocessor.kernel_name=$kernel"
fi

# We'll need some badges:
badge_dir='.badges'
web_dir='https://raw.githubusercontent.com/LSSTDESC/beavis-ci/master/badges/'
mkdir -p $badge_dir
curl -s -o $badge_dir/failing.svg $web_dir/failing.svg
curl -s -o $badge_dir/passing.svg $web_dir/passing.svg

# Get the list of available notebooks:
notebooks=`find . -path '*/.ipynb_checkpoints/*' -prune -o -name "${notebook_name}.ipynb" -print`
echo "$notebooks"

# Now loop over notebooks, running them one by one:
declare -a outputs
declare -a logs
SUCCESS=1
for notebook in $notebooks; do

    filename=`basename $notebook`
    filedir=`dirname $notebook`
    filename_noext=${filename%.*}

    cd $repo_full_path
    cd $filedir
    mkdir -p log
    logs+=( "$filedir/log" )

    logfile="log/${filename_noext}.log"
    svgfile="log/${filename_noext}.svg"
    output="$filedir/${filename_noext}.${ext}"

    # Run the notebook:
    $jupyter nbconvert $kernel_option \
        --ExecutePreprocessor.startup_timeout=120 \
        --ExecutePreprocessor.timeout=1200 \
        --to $outputformat \
        --execute $filename &> $logfile

    cd $repo_full_path
    if [ -e $output ]; then
        outputs+=( $output )
        echo "SUCCESS: $output produced."
        cp $badge_dir/passing.svg $filedir/$svgfile
    else
        echo "WARNING: failed to produce $output. See $repo_full_path/$filedir/$logfile for details."
        cp $badge_dir/failing.svg $filedir/$svgfile
        SUCCESS=0
    fi

done

if [ $commit -eq 0 ]; then
    sleep 0

else
    echo "Attempting to push the rendered outputs to GitHub in an orphan branch $target"

    cd $repo_full_path
    git branch -D $target >& /dev/null
    git checkout --orphan $target
    git rm -rf . >& /dev/null
    git add -f "${outputs[@]}"
    git add -f "${logs[@]}"
    git commit -m "pushed rendered notebooks and log files"
    if [ $push -gt 0 ]; then
        git push -q -f origin $target
    fi
fi

echo "beavis-ci finished!"
if [ $SUCCESS -eq 0 ]; then
    echo "WARNING: Some notebooks did not rendered successfully!"
fi
if [ $push -gt 0 ]; then
    echo "View results at https://github.com/${repo}/tree/${target}/"
fi

cd ../../
date

# ======================================================================
