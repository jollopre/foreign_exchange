#!/bin/bash
. /root/env.sh
cd $WORKDIR
bundle exec rails runner "ExchangeRate.update" >> $WORKDIR/log/cron.log 2>&1