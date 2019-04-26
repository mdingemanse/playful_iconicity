# coding: utf-8
# billdthompson@berkeley.edu
# wdt@princeton.edu

import pysnooper
import numpy as np
import pandas as pd
import json
import click
import logging
logging.basicConfig(format='%(levelname)s > %(message)s', level=logging.INFO)


@click.command()
@click.option('--datafile', '-d')
def run(datafile):
	df = pd.read_csv(datafile)

	# http://practicalcryptography.com/cryptanalysis/letter-frequencies-various-languages/english-letter-frequencies/
	with open('letter-freq-dict.txt', 'r') as f:
		letterfreqs = json.loads(f.read())

	# @pysnooper.snoop()
	def logletterfreq(row):

		if not isinstance(row.word, str):
			return None

		letters = list(row.word.upper())

		freqs = map(letterfreqs.get, letters)

		probs = np.fromiter(freqs, dtype = float) / 100.

		mean = probs.mean()

		logmean = np.log(mean)

		return logmean

	df['logletterfreq'] = df.apply(logletterfreq, axis = 1)

	df.to_csv(datafile.replace('.csv', '-logletterfreq.csv'))

if __name__ == '__main__':
    run()