MIXED sc_rACC BY Group Run Instruction Performance WITH QI Age 
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE) 
  /FIXED=Instruction Run*Performance | SSTYPE(3) 
  /METHOD=ML 
  /PRINT=DESCRIPTIVES  SOLUTION 
  /RANDOM=INTERCEPT | SUBJECT(Participant) COVTYPE(ID) 
  /EMMEANS=TABLES(Instruction) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(Run*Performance) COMPARE(Performance) ADJ(BONFERRONI) .
