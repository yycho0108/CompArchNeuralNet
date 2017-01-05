#!/usr/bin/python

import numpy as np
import sys
from matplotlib import pyplot as plt

def sigmoid(x):
    return 1.0 /(1.0 + np.exp(-x))
def fast_sigmoid(x):
    return 0.5*(1 +  x / (1.0 + np.abs(x)))

# x -> abs(x) -> 1.0 + % -> x/% -> 1 + % - 0.5 * %
def main():
    if sys.argv[1].lower() == 'plot':
        xs = np.linspace(-10,10,200)
        ys = sigmoid(xs)
        p = np.polyfit(xs, ys, 5)
        f = np.poly1d(p)

        plt.plot(xs,ys)
        plt.plot(xs,fast_sigmoid(xs))
        plt.plot(xs,f(xs))


        plt.title('Approximated Sigmoid')
        plt.legend(['sigmoid', 'fast sigmoid', 'polyfit'], loc='lower right')

        plt.show()
    else:
        x = float(sys.argv[1])
        print 'sigmoid :', sigmoid(x)
        print 'approx :', fast_sigmoid(x)

if __name__ == "__main__":
    main()


