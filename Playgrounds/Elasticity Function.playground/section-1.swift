// Elasticity function

// x = current point
// li = initial elastic point
// lf = elastic limit point

import Foundation

let π = Float(M_PI)

func elasticPoint(x: Float, li: Float, lf: Float) -> Float {
	if (fabs(x) >= fabs(li)) {
		return atanf(tanf((π*li)/(2*lf))*(x/li))*(2*lf/π)
	} else {
		return x
	}
}

for n in -250 ..< 250 {
	elasticPoint(Float(n), 100, 150)
}
