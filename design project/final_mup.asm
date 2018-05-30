#make_BIN#

; set loading address, .bin file will be loaded to this address:
#LOAD_SEGMENT=ffffh#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=0000h#	; same as loading segment
#IP=0000h#	; same as loading offset

; set segment registers
#DS=0000h#	; same as loading segment
#ES=0000h#	; same as loading segment

; set stack
#SS=0000h#	; same as loading segment
#SP=FFFEh#	; set to top of loading segment

; set general registers
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#   



; add your code here 

         
         
         jmp     st1 ;jump to the main function.
         db     1021 dup(0) ;fill up unadressed memory.
         hr db 00h ; hour count
         spr db 0ffh ; sprinkler values
         std_value db 80h ; standard value for moisture. above this means that we need water to be turned on/off.
         run db 2 
          
         
;main program          
         st1:      cli 
         
; intialize ds, es,ss to start of RAM
          mov       ax,0200h
          mov       ds,ax
          mov       es,ax
          mov       ss,ax
          mov       sp,0FFFEH
         
; 8255(1) is for storing values from adcs and connecting to sprinklers
; 8255(2) is for controlling the two ADCs
; 8255(3) if for updating the hr register using port A    

; assigning memory location to 8255(1) 
        creg1 equ 06h
        porta1 equ 00h
        portb1 equ 02h
        portc1 equ 04h 
        
; assigning memory location to 8255(3)   
        creg2 equ 16h
        porta2 equ 10h
        portb2 equ 12h
        portc2 equ 14h 
        
; assigning memory location to 8255(2) 
        creg3 equ 0eh
        porta3 equ 08h
        portb3 equ 0ah
        portc3 equ 0ch     
        
; assigning memory location to 8253  
        cnt0 equ 18h
        cnt1 equ 1ah
        cnt2 equ 1ch
        cre2 equ 1eh

; initialise timer - 8253   
 
mov al,00010101b
out cre2, al ;counter0 sent to rate generator mode.
mov al,10
out cnt0, al ;10 seconds is our equivalent of one hour.
      
     
; initialise 8255(1)
mov al,92h
out creg1,al    
mov porta1, 00h
mov portb1, 00h
mov al, 00h 
out portc1, al

      
; initialise 8255(3) 
mov al,92h
out creg2,al 
      

; initialise 8255(2)
mov al,9Ah
out creg3,al   
      

;to check for time
     
     
       
time: lea si,hr
      mov [si],0

             
X1:   in al,porta2 
      cmp al,0  ;checks if the timing is 0. our program starts at 12.00 am.
      je X2
      jmp x1   
      
     
      
X2:   
      inc [si] 
      cmp [si],11
      jmp spr1 ;after 11 hours pass. our sprinkler is switched on.
      
      cmp [si],18
      je spr1 ; at 18.00 hrs sprinkler is turned on again.
      cmp [si],24
      je time ; at 24.00 hrs sprinkler is reset.
      jmp X1
       
spr1:                 
    
       
      mov al,30h ; sensors of sprinkler 1 selected.
      call conversion ;conversion function checks whether adc conversion is complete or not.
      mov al,0f8h ; sensor of sprinkler 2 selected.
      out 0ch,al  ; signals that end of covnversion is reahed at both adcs.
      
      compare1:in al,porta1 ;output of adc1 sent to port a of 8255(1)
               cmp al, std_value ;to check whether 8th sensors output returned from ADC(1) is lower than standard value. 8255(1) port A.
               jge make_bit_high1 ;it is higher. so switch off/dont change.
              
               in al, 02h
               cmp al, std_value ;checks second sensor for the same sprinkler which happens to be connected to ADC(2). 8255(1) port B.
               jge make_bit_high1
              
    
      make_bit_low1: and spr,0feh ;turns on the LED (sprinkler). common anode.
                    jmp spr2
                  
      make_bit_high1: or spr,01h ; switch off the sprinkler/led.
                     jmp spr2    
                     
                     
    
spr2: mov al,31h
      call conversion 
      mov al,0fch
      out 0ch,al
      
      compare2:in al,00h
              cmp al, std_value
              jge make_bit_high2
              
              in al, 02h
              cmp al, std_value
              jge make_bit_high2
              
    
      make_bit_low2: and spr,0fdh
                    jmp spr3
                  
      make_bit_high2: or spr,02h
                     jmp spr3
    

spr3: mov al,32h
      call conversion 
      mov al,0fah
      out 0ch,al
      
      compare3:in al,00h
              cmp al, std_value
              jge make_bit_high3
              
              in al, 02h
              cmp al, std_value
              jge make_bit_high3
              
    
      make_bit_low3: and spr,0fbh
                    jmp spr4
                  
      make_bit_high3: or spr,04h
                     jmp spr4
                     
       
spr4: mov al,33h
      call conversion 
      mov al,0feh
      out 0ch,al
      
      compare4:in al,00h
              cmp al, std_value
              jge make_bit_high4
              
              in al, 02h
              cmp al, std_value
              jge make_bit_high4
              
    
      make_bit_low4: and spr,0f7h
                    jmp spr5
                  
      make_bit_high4: or spr,08h
                     jmp spr5

spr5: mov al,34h
      call conversion 
      mov al,0f9h
      out 0ch,al
      
      compare5:in al,00h
              cmp al, std_value
              jge make_bit_high5
              
              in al, 02h
              cmp al, std_value
              jge make_bit_high5
              
    
      make_bit_low5: and spr,0efh
                    jmp spr6
                  
      make_bit_high5: or spr,10h
                     jmp spr6
                     
spr6: mov al,35h
      call conversion 
      mov al,0fdh
      out 0ch,al
      
      compare6:in al,00h
              cmp al, std_value
              jge make_bit_high6
              
              in al, 02h
              cmp al, std_value
              jge make_bit_high6
              
    
      make_bit_low6: and spr,0dfh
                    jmp spr7
                  
      make_bit_high6: or spr,20h
                     jmp spr7  
                     
spr7: mov al,36h
      call conversion 
      mov al,0fbh
      out 0ch,al
      
      compare7:in al,00h 
              cmp al, std_value
              jge make_bit_high7
              
              in al, 02h
              cmp al, std_value
              jge make_bit_high7
              
    
      make_bit_low7: and spr,0bfh
                    jmp spr8
                  
      make_bit_high7: or spr,40h
                     jmp spr8
                                       
spr8: mov al,37h
      call conversion 
      mov al,0ffh
      out 0ch,al
      
      compare8:in al,00h
              cmp al, std_value 
              jge make_bit_high8
              
              in al, 02h
              cmp al, std_value 
              jge make_bit_high8
              
    
      make_bit_low8: and spr,7fh
                    jmp final
                  
      make_bit_high8: or spr,80h
                     jmp final
                     
final: mov al, spr
       out 04h, al
       
       ; to give a delay. so that plants are watered.
       call delay
       
       ; check if all sprinklers are off
       cmp spr, 0ffh                        
       
       ;if all off, go back to checking hr
       jz x1
       
       ;if some sprinkler is still on, check sensor values again
       jmp spr1
       
conversion proc near
           ;this procedure is used to check whether conversion from analoag to digital is complete or not.
           out 0ch,al
           back: in al,0ch
                 and al,11000000b
                 cmp al,11000000b
                 jne back
                 pop dx
                 pop cx
                 popf
           
           RET
conversion endp 

delay proc near ; a simple delay loop.
      mov cx,7d00h
x0:   nop
      loop x0
delay endp
                     
HLT           ; halt!