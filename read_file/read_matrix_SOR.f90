SUBROUTINE read_matrix_SOR
	USE typedef, only: n_var,A,b,solution,i_row,i_col
	USE IO_control, ONLY: file_route,status
	IMPLICIT NONE
	CHARACTER(LEN=256) dum
	
	OPEN(666,FILE=file_route,STATUS='OLD',POSITION='REWIND')
	!skip first line
	READ(666,'(A)',IOSTAT=status) dum
	
	DO WHILE (.TRUE.)
		READ(666,'(A)',IOSTAT=status) dum
		IF(status<0 .OR. dum(1:3)=='END') EXIT
		
		IF (dum(1:1)=='*' .OR. dum(1:1)=='#') THEN
			IF (dum(3:21)=='number of variables') THEN
				READ(666,*,IOSTAT=status) n_var
				ALLOCATE(A(n_var,n_var))
				ALLOCATE(b(n_var))
				ALLOCATE(solution(n_var))
			ELSEIF(dum(3:9)=='martrix') THEN
				DO i_row=1,n_var
					!Due to how anti-human a fortran arrays distribute is
					READ(666,*,IOSTAT=status)  (A(i_row,i_col),i_col=1,n_var),b(i_row)
				ENDDO
			ENDIF
			IF(status<0) CALL error_output(2)
			IF(status>0) CALL error_output(3)
		ENDIF
	ENDDO
	CLOSE(666)
	
	IF(isNaN(A(n_var,n_var))) CALL error_output(4)
	
END SUBROUTINE read_matrix_SOR
	
