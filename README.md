# beavis-ci
Enable occasional integration and testing of jupyter notebooks. Like travis-ci but dumber.

`beavis-ci` uses jupyter nbconvert to render all the jupyter notebooks in a folder (and its subfolders), and then pushes the 
rendered notebooks to GitHub in an orphan (i.e. history-less) branch. When you run `beavis-ci` in a cron job, you are semi-continuously 
intgrating and testing your jupyter notebooks.

## Usage
Download the `beavis-ci.sh` script and put it on your path, e.g.:
```
curl -o ~/bin/beavis-ci.sh https://raw.githubusercontent.com/LSSTDESC/beavis-ci/master/beavis-ci.sh
chmod a+x ~/bin/beavis-ci.sh
```
Optional inputs to the script are given in the script header, which is printed with
```
beavis-ci.sh -h
```

For `beavis` to be able to push the rendered notebooks to your GitHub repo, you'll need to provide your `GITHUB_USERNAME` and `GITHUB_API_KEY`, either as environment variables or with the `-u` and `-k` options. 

You might like to copy the [example README.rst file]() in the `tests` directory, to make your own index table of notebooks with build passing/failing badges.  

## Contact, License etc
The `beavis-ci` script is provided for general use under the [3-clause modified BSD license](LICENSE). If you hit problems when using it or would otherwise like to help make it better, please [open an issue](https://github.com/LSSTDESC/beavis-ci/issues).

Authors:
* Phil Marshall (@drphilmarshall)
* Yao-Yuan Mao (@yymao)
