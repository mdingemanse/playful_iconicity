# -*- coding: utf-8 -*-
# biltho@mpi.nl

import csv
import click
import logging
import warnings
import numpy as np
import pandas as pd
from scipy.stats import pearsonr
from sklearn.linear_model import Ridge as RR
from sklearn.model_selection import train_test_split as tts

D = 300 # skipgram vector dimension
VECTORDIMENSIONS = ['d_{0}'.format(d) for d in range(D)]

@click.command()
@click.option('--norms', '-n', default='combined-experimental-norms.csv')
@click.option('--vecfile', '-v', default='wiki.en.vec')
@click.option('--expand', '-e', multiple = True)
@click.option('--verbose', default=False, is_flag = True)
def run(norms, vecfile, expand, verbose):

	# admin
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.INFO) if verbose else logging.basicConfig(format='%(levelname)s: %(message)s', level=None)
	warnings.filterwarnings(action="ignore", module="scipy", message="^internal gelsd")

	# norms
	click.secho("Reading norms from: {}".format(norms), fg = 'green')
	data = pd.read_csv(norms).drop_duplicates(subset = 'word')
	data['word'] = data.word.str.lower()

	# vectors
	click.secho("Reading vectors from: {}".format(vecfile), fg = 'yellow')
	vecs = pd.read_csv(vecfile, sep = ' ', quoting = csv.QUOTE_NONE, skiprows = 1, header = None, names = ['word'] + VECTORDIMENSIONS + ['ignore']).drop_duplicates(subset = ['word']).drop(columns = 'ignore').merge(data, on = 'word', how = 'inner')

	logging.info("Computing predictions for: {}".format(expand))

	for norm in list(expand):

		# identify training material
		experimental = vecs[norm].notnull()

		# learn the regression
		mu = data[norm].mean()
		X = vecs[experimental][VECTORDIMENSIONS].values
		y = vecs[experimental][norm].values - mu
		rr = RR()
		rr.fit(X, y)

		# predict new values
		vecs[norm + '_imputed'] = rr.predict(vecs[VECTORDIMENSIONS].values) + mu
	
	newfn = norms.replace('.csv', '') + '-with-{}-predictions.csv'.format('-'.join(expand))
	vecs = vecs.drop(columns = VECTORDIMENSIONS)
	logging.info("Saved results to {}".format(newfn))
	logging.info("Correlation between predicted and observed norms:\n{}".format(vecs.corr()[[col for col in vecs.columns if col in expand or '_imputed' in col]]))
	vecs.to_csv(newfn, index = False)

	click.secho("===============================", fg = "yellow")


if __name__ == '__main__':
	run()