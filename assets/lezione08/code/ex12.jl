# This file was generated, do not modify it. # hide
# Al posto della condizione iniziale, passiamo `result` (la
# soluzione al tempo t=h), e al posto del tempo 0.0 passiamo
# il tempo 0.0+h
result = euler(oscillatore, result, 0. + h, h)