# beavis-ci
Enable occasional integration and testing of jupyter notebooks. Like travis-ci but dumber.

`beavis-ci` uses jupyter nbconvert to render all the jupyter notebooks in a repository (including its subfolders), and then pushes the
rendered notebooks to GitHub in an orphan (i.e. history-less) branch. When you run `beavis-ci` in a cron job, you are semi-continuously
intgrating and testing your jupyter notebooks.

## Usage
Download the `beavis-ci.sh` script and put it on your path, e.g.:
```
curl -o ~/bin/beavis-ci.sh https://raw.githubusercontent.com/LSSTDESC/beavis-ci/master/beavis-ci.sh
chmod a+x ~/bin/beavis-ci.sh
```

Run the script with your target repo as the only argument, like this:
```
beavis-ci.sh LSSTDESC/beavis-ci
```

Additional, optional, inputs to the script are described in the script header, which you can print
```
beavis-ci.sh -h
```

Here's an example cron job, that runs `beavis-ci.sh` every 6 hours, at 5 minutes to the hour:
```
55  3,9,15,21  *  *  * ( bin/beavis-ci.sh LSSTDESC/DC2-analysis -k <GITHUB_API_KEY> -u <username> )
```
(To schedule, and then adjust, your cron jobs, do `crontab -e` - and make a note of which host you are on!)

> For `beavis` to be able to push the rendered notebooks to your GitHub repo, you'll need to provide your `GITHUB_USERNAME` and `GITHUB_API_KEY`, either as environment variables or with the `-u` and `-k` options.

> You might like to copy the [example README.rst file]() in the `tests` directory, to make your own index table of notebooks with build passing/failing badges.  

## Contact, License etc
The `beavis-ci` script is provided for general use under the [3-clause modified BSD license](LICENSE). If you hit problems when using it or would otherwise like to help make it better, please [open an issue](https://github.com/LSSTDESC/beavis-ci/issues).

Authors:
* Phil Marshall (@drphilmarshall)
* Yao-Yuan Mao (@yymao)
