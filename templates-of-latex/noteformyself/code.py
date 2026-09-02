import numpy as np
from numpy.polynomial import Polynomial

# Example: create two integer matrices
A = np.array([[1,1,0], [4,0,1], [1,0,0]], dtype=int)
B = np.array([[2,1,0], [4,1,1],[1,0,1]], dtype=int)

# Matrix addition

# Matrix multiplication
def M(i, j):
    return np.linalg.matrix_power(A, i) @ np.linalg.matrix_power(B, j)

mul_result = M(1, 1)

def rho(A):
    eigvals = np.linalg.eigvals(A)
    return np.max(np.abs(eigvals))

# Spectral radius
results = {}
for i in range(-10, 11):
    for j in range(-10, 11):
        m = M(i, j)
        results[(i, j)] = rho(m)

# Print results
# for key in sorted(results.keys()):
#     print(f"rho(M({key[0]}, {key[1]})) = {results[key]}")

print("A =" , A)
print("B =" , B)
print("A * B =" , mul_result)
print("B * A =" , np.matmul(B, A))

print("Eigenvalues of A:", np.linalg.eigvals(A))
print("Eigenvalues of B:", np.linalg.eigvals(B))

def char_poly(matrix):
    # Get coefficients of the characteristic polynomial
    coeffs = np.poly(matrix)
    # Format as a string
    terms = []
    deg = len(coeffs) - 1
    for i, c in enumerate(coeffs):
        power = deg - i
        if power == 0:
            terms.append(f"{c:.2f}")
        elif power == 1:
            terms.append(f"{c:.2f}*x")
        else:
            terms.append(f"{c:.2f}*x^{power}")
    return " + ".join(terms)

print("Characteristic polynomial of A:")
print(char_poly(A))
print("Characteristic polynomial of B:")
print(char_poly(B))