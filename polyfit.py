#!/usr/bin/python

import numpy as np
from matplotlib import pyplot as plt

def test(x):
    print '{} : {} sec.'.format(x, f(x))

x = [10,20,30,40,50,60,100,150,300, 400, 784] # number of inputs
y = [.43,.86,1.37,2.00,2.64,3.38,7.69,16.68,90.73, 165, 678.52] # time taken

p = np.polyfit(x,y,2)
print p
f = np.poly1d(p)

xs = range(784)
plt.plot(x, y, 'o')
plt.plot(xs, f(xs))
plt.legend(['measured time','deduced time'])
plt.show()

test(784)
