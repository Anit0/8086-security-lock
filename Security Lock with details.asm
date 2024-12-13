;-----------------
      .DATA                             
DATA2 DB  5,?,5 DUP (?)        ; Define a buffer for storing ID input
DATA3 DB 'ENTER YOUR ID: ','$' ; Message to prompt for ID
DATA1 DB '0123456789ABCDEFabcdef?' ; Valid characters for ID
DATA4 DB 'EROR:THE ID NUMBER MUST BE 4-BIT HEX','$' ; Error message for invalid ID
DATA5 DB 'WRONG ENTRY: Your ID must contain data from 0-->9 or A-->F','$' ; Invalid entry message for ID
DATA6 DW 0AAAAH,0BBBBH,0CCCCH,0DDDDH,0EEEEH,0FFFFH,1111H,2222H,3333H,4444H ; Some predefined IDs
DATA7 DW 5555H,6666H,7777H,8888H,9999H,0100H,0200H,0300H,0400H,5667H ; More predefined IDs
DATA8 DW 1111H,2222H,3333H,4444H,5555H,6666H,000AH,000BH,000CH,000DH ; More predefined IDs
DATA9 DW 000FH,000EH,0001H,0002H,0003H,0A00H,0B00H,0C00H,0D00H,0A0AH ; Additional IDs
DATAA DB 'Your ID is wrong, Please try again!!','$' ; Error message for wrong ID
DATAB DB 'ENTER YOUR PASSWORD: ','$' ; Message to prompt for password
DATAC DB 5,?,5 DUP (?)        ; Buffer for storing password input
DATAP DB 5,?,5 DUP (?)        ; Another buffer for password
DATAD DB '******WELCOME******','$' ; Welcome message after successful entry
DATAE DB 'WRONG PASSWORD,TRY AGAIN','$' ; Error message for wrong password
DATAF DB 00H                 ; Placeholder for a variable or flag
DATAG DB '---------------------------------------------------------------','$' ; Decorative separator
DATAH DB 'WHAT DO YOU WANT','$' ; Prompt asking for action choice
DATAI DB '(1) Enter your ID and PASSWORD','$' ; Option 1 description
DATAJ DB '(2) Change your Password','$' ; Option 2 description
DATAU DB 'Your choice is (1/2) ','$' ; Prompt for user choice (1 or 2)
DATAT DB 'EROR:WRONG CHOICE','$' ; Error message for invalid choice
DATAK DB 2,?,2 DUP (?)        ; Buffer for storing choice
DATAR DB 'ENTER YOUR ID: ','$' ; Repeated message to prompt for ID
DATAQ DB 'ENTER OLD PASSWORD: ','$' ; Prompt for old password
DATAY DB 'ENTER NEW PASSWORD: ','$' ; Prompt for new password
DATAO DB 'CONFIRM YOUR PASSWORD: ','$' ; Prompt for password confirmation
DATAV DB 'YOUR PASSWORD IS SUCCESSFULLY CHANGED','$' ; Success message for password change
DATAW DB 'WRONG ENTRY!! PLEASE, RE-ENTER NEW PASSWORD: ','$' ; Error message for incorrect password entry
DATAZ DW ?                   ; Placeholder for variable
;-----------------
               .CODE
MAIN             PROC FAR      
                 MOV AX,@DATA            ; Initialize data segment address into AX
                 MOV DS,AX               ; Set DS to the data segment address
                 MOV ES,AX               ; Set ES to the data segment address
                 MOV DH,00H              ; Initialize DH register to 0
                 CALL CLEAR              ; Clear the screen
                 MOV BP,OFFSET DATAF     ; Set BP to point to DATAF for cursor positioning
START:           CALL SETCURSOR          ; Set the cursor position
                 CALL ENTRY              ; Display menu options and prompt for action
                 CALL GETCHOICE          ; Get the user's choice (1 or 2)
                 CALL CHECKNO            ; Check if the choice is valid (1 or 2)
                 CALL SETCURSOR          ; Set the cursor again to organize display
                 CALL ENTERORCHANGE      ; Check if the user wants to enter or change password
                 CALL HANDLE             ; Handle the process based on the user's input
                 CALL CONVERT            ; Convert and update password if needed
ID:              CALL WELCOME            ; Display welcome message
                 CALL GET_IN             ; Get user ID input
                 CALL NO.LET             ; Ensure ID has 4 digits
                 CALL CHECK              ; Validate the ID
                 MOV SI,OFFSET DATA2+2   ; Point SI to ID buffer
                 CALL PUTIDINAX          ; Put ID into AX for further processing
                 CALL CHECKID            ; Check if ID is valid
                 CALL SETCURSOR          ; Set cursor for display formatting
                 CALL GETPASS            ; Get password input
                 MOV SI,OFFSET DATAC+2   ; Point SI to password buffer
                 CALL PUTIDINAX          ; Put password into AX
                 CALL CHECKPASS          ; Check if password is valid
                 CALL SETCURSOR          ; Set cursor for display formatting
                 CALL ENTER              ; Display confirmation message
NO_EROR:         CALL SETCURSOR          ; Set cursor again
                 CALL NOEROR             ; Handle invalid input
WR_ENT:          CALL SETCURSOR          ; Set cursor for re-entry
                 CALL WRONGENTRY         ; Handle wrong entry error
WRONGID:         CALL SETCURSOR          ; Set cursor for wrong ID
                 CALL WRONG_ID           ; Handle wrong ID entry
WRONGPASS:       CALL SETCURSOR          ; Set cursor for wrong password
                 CALL WRONG_PW           ; Handle wrong password entry
OPERA:           MOV AH,4CH             ; Terminate the program
                 INT 21H                 ; DOS interrupt for program exit
MAIN             ENDP        
;----------------
CLEAR            PROC   
                 MOV AX,0600H            ; Function to clear screen
                 MOV BH,07               ; Attribute for normal text
                 MOV CX,0000             ; Starting column (0)
                 MOV DH,24               ; Row 24 (bottom of the screen)
                 MOV DL,79               ; Column 79 (rightmost column)
                 INT 10H                  ; BIOS interrupt to clear screen
                 RET
CLEAR            ENDP
;----------------     
ENTRY            PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATAH
                 INT 21H                 ; Display prompt 'WHAT DO YOU WANT'
                 CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAI
                 INT 21H                 ; Display option (1) Enter ID & Password
                 CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAJ
                 INT 21H                 ; Display option (2) Change Password
                 CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAU
                 INT 21H                 ; Prompt for choice input
                 RET
ENTRY            ENDP
;--------------  
GETCHOICE        PROC
                 MOV AH,0AH             ; DOS function for buffered input
                 MOV DX,OFFSET DATAK     ; Address of buffer
                 INT 21H                 ; Interrupt to get user input
                 RET
GETCHOICE        ENDP
;-----------------
CHECKNO          PROC
                 LEA BX,DATAK+2          ; Load buffer address for choice
                 CMP [BX],31H            ; Compare if choice is '1'
                 JZ  RETURN2
                 CMP [BX],32H            ; Compare if choice is '2'
                 JZ  RETURN2
                 CALL EROR               ; If neither, show error
RETURN2:         CALL 5AT
                 RET
CHECKNO          ENDP
;--------------- 
EROR             PROC
                 CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAT     ; Error message for wrong choice
                 INT 21H
                 CALL 5AT
                 JMP START
                 RET
EROR             ENDP
;-------------- 
SETCURSOR        PROC 
                 MOV AH,02H             ; Set cursor position function
                 MOV BH,00              ; Page number
                 MOV DL,00              ; Column position
                 MOV DH,DS:[BP]         ; Row position from BP
                 INT 10H                 ; BIOS interrupt to move cursor
                 ADD DS:[BP],1           ; Increment BP for next cursor position
                 RET
SETCURSOR        ENDP
;----------------
WELCOME          PROC     
                 MOV AH,09H
                 LEA DX,DATA3           ; Display 'ENTER YOUR ID'
                 INT 21H
                 RET
WELCOME          ENDP      
;---------------- 
GET_IN           PROC
                 MOV AH,0AH
                 MOV DX,OFFSET DATA2     ; ID input buffer
                 INT 21H                 ; DOS interrupt to get user input
                 RET
GET_IN           ENDP    
;----------------
NO.LET           PROC
                 LEA SI,DATA2+1          ; Point to ID input buffer
                 CMP [SI],04H            ; Check if input length is 4
                 JNZ NO_EROR             ; If not, show error
                 RET       
NO.LET           ENDP         
;----------------        
CHECK            PROC
                 MOV AH,4
                 LEA SI,DATA2+2
AGAIN:           LEA DI,DATA1
                 MOV CX,23  
                 MOV AL,[SI]            ; Compare input with valid characters
                 REPNZ SCASB
                 CMP CX,00
                 JZ  END                 ; If match, continue
                 INC SI
                 DEC AH
                 JNZ AGAIN 
                 RET
END:             JMP WR_ENT
CHECK            ENDP
;---------------- 
NOEROR           PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATA4     ; Error message for invalid ID
                 INT 21H  
                 CALL 5AT
                 JMP START
                 RET
NOEROR           ENDP
;---------------    
WRONGENTRY       PROC    
                 MOV AH,09H
                 MOV DX,OFFSET DATA5     ; Error message for invalid entry
                 INT 21H 
                 CALL 5AT
                 JMP START
                 RET
WRONGENTRY       ENDP
;-------------- 
PUTIDINAX        PROC                  
                 MOV CX,04H
AGAIN2:          CMP [SI],39H            ; Check if character is within valid range (0-9)
                 JZ  ZERO
                 JB  ZERO
                 JA  OVER    
ZERO:            SUB [SI],30H             ; Convert from ASCII to numeric
                 JMP STAR         
OVER:            CMP [SI],70              ; Check for uppercase letters
                 JZ  CAPITAL
                 JB  CAPITAL
                 JA  SMALL
CAPITAL:         SUB [SI],55              ; Convert to uppercase letters
                 JMP STAR 
SMALL:           SUB [SI],87              ; Convert to lowercase letters
                 JMP STAR       
STAR:            INC SI                    ; Move to next character
                 DEC CX                   ; Decrement counter
                 JNZ AGAIN2
                 SUB SI,4                 ; Adjust pointer back by 4
                 MOV AH,[SI]              ; Place ID into AX
                 MOV AL,[SI+2]
                 MOV BH,[SI+1]
                 MOV BL,[SI+3]
                 SHL AX,4
                 OR  AX,BX  
                 RET
PUTIDINAX        ENDP
;--------------         
CHECKID          PROC
                 MOV CX,21                ; Set the counter to 21
                 LEA DI,DATA6             ; Point to predefined IDs
                 CLD                      ; Clear direction flag (auto-increment)
                 REPNE SCASW              ; Compare ID with predefined IDs
                 CMP CX,0000H             ; If match found, jump
                 JZ WRONGID               ; If no match, show wrong ID message
                 RET          
CHECKID          ENDP
;-------------- 
WRONG_ID         PROC 
                 MOV AH,09H
                 MOV DX,OFFSET DATAA      ; Show error message for wrong ID
                 INT 21H     
                 CALL 5AT
                 JMP START
                 RET
WRONG_ID         ENDP
;------------- 
GETPASS          PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATAB      ; Show password prompt
                 INT 21H   
                 MOV AH,0AH
                 MOV DX,OFFSET DATAC      ; Get password input
                 INT 21H
                 RET             
GETPASS          ENDP
;------------- 
CHECKPASS        PROC   
                 MOV BX,AX
                 ADD DI,38                ; Add offset to password
                 CMP BX,[DI]              ; Check if password matches
                 JNZ WRONGPASS 
                 RET
CHECKPASS        ENDP      
;------------- 
ENTER            PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATAD      ; Show welcome message
                 INT 21H 
                 CALL 5AT 
                 JMP START
                 RET
ENTER            ENDP
;------------          
WRONG_PW         PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATAE      ; Show error message for wrong password
                 INT 21H   
                 CALL 5AT
                 JMP START
WRONG_PW         ENDP     
;------------  
5AT              PROC  
                 CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAG      ; Show separator line
                 INT 21H
                 RET
5AT              ENDP
;-----------       
ENTERORCHANGE    PROC
                 LEA BX,DATAK+2
                 CMP [BX],31H            ; If choice is 1, proceed to ID entry
                 JZ  ID
                 RET
ENTERORCHANGE    ENDP  
;--------------     
HANDLE           PROC
                 MOV AH,09H
                 MOV DX,OFFSET DATAR      ; Prompt for old password
                 INT 21H
                 CALL GET_IN 
                 CALL NO.LET
                 CALL CHECK               ; Check if ID exists
                 MOV  SI,OFFSET DATA2+2
                 CALL PUTIDINAX           ; Put ID in AX
                 CALL CHECKID
                 MOV BX,OFFSET DATAZ      ; Placeholder for password verification
                 LEA DX,[DI]       
                 MOV [BX],DX
                 CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAQ      ; Prompt for old password again
                 INT 21H
                 MOV AH,0AH
                 MOV DX,OFFSET DATAC      ; Get new password
                 INT 21H        
                 MOV  SI,OFFSET DATAC+2
                 CALL PUTIDINAX           ; Store new password in AX
                 CALL CHECKPASS
                 CALL SETCURSOR 
                 MOV AH,09H
                 MOV DX,OFFSET DATAY      ; Prompt for password confirmation
                 INT 21H
AGAIN3:          MOV AH,0AH
                 MOV DX,OFFSET DATAC      ; Get confirmation password
                 INT 21H  
                 CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAO      ; Display confirmation message
                 INT 21H
                 MOV AH,0AH
                 MOV DX,OFFSET DATAP      ; Get password input for confirmation
                 INT 21H 
                 CALL CHECKCONFIRM        ; Check if confirmation matches
                 RET
HANDLE           ENDP
;--------------- 
CHECKCONFIRM     PROC  
                 CLD
                 MOV SI,OFFSET DATAC+2
                 MOV DI,OFFSET DATAP+2
                 MOV CX,05H
                 REPE CMPSB 
                 CMP CX,0000H
                 JNZ  PUTITAGAIN          ; If mismatch, prompt to try again
                 RET
PUTITAGAIN:      CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAW      ; Show error for password mismatch
                 INT 21H
                 JMP AGAIN3 
CHECKCONFIRM     ENDP
;--------------  
CONVERT          PROC
                 MOV SI,OFFSET DATAP+2
                 CALL PUTIDINAX           ; Store new password in AX
                 MOV BX,OFFSET DATAZ
                 ADD [BX],38              ; Convert password
                 MOV DI,[BX]             
                 MOV [DI],AX
                 CALL SETCURSOR
                 MOV AH,09H
                 MOV DX,OFFSET DATAV      ; Success message for password change
                 INT 21H 
                 CALL 5AT
                 JMP START   
CONVERT          ENDP          
;-------------
                 END MAIN
