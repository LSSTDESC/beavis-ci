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

Here's an example cron job, that runs `beavis-ci.sh` every 6 hours, at 5 minutes to the hour, and pushs the results to GitHub:
```
55  3,9,15,21  *  *  * ( bin/beavis-ci.sh LSSTDESC/DC2-analysis --push )
```
(To schedule, and then adjust, your cron jobs, do `crontab -e` on NERSC. The cron jobs you set up will stay with the specific node. You can find out the node host name in the email cron sends you.)


## Contact, License etc
The `beavis-ci` script is provided for general use under the [3-clause modified BSD license](LICENSE). If you hit problems when using it or would otherwise like to help make it better, please [open an issue](https://github.com/LSSTDESC/beavis-ci/issues).

Authors:
* Phil Marshall (@drphilmarshall)
* Yao-Yuan Mao (@yymao)
