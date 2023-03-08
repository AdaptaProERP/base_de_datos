// Programa   : DPEDITSETDEF
// Fecha/Hora : 03/05/2014 01:42:37
// Propósito  : Asignar Valor por Defecto a CLASE DPEDIT
// Creado Por : Juan Navas
// Llamado por: DPEDIT/CREATEVARS, Tambien debe ser ejecutado en presave
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oFrm)
   LOCAL nAt,cTable,aDefault,I,uValue,cType,aZero:={}

//? oDp:lRunDefault,"oDp:lRunDefault " 

   IF !oDp:lRunDefault 
      RETURN NIL
   ENDIF

   IF Empty(oDp:aDefault)
     oDp:aDefault:=EJECUTAR("GETDEFAULTALL")
   ENDIF

   IF oFrm=NIL
      EJECUTAR("DPUSUARIOS",1) 
      oFrm:=oUSUARIOS 
   ENDIF

   IF oFrm:ClassName()="TDOCENC"
     cTable:=oFrm:cTable
   ELSE
     cTable  :=oFrm:oTable:cTable
   ENDIF

   cTable  :=ALLTRIM(cTable)

   nAt     :=ASCAN(oDp:aDefault,{|a,n|a[1]==cTable})
   aDefault:=IF(nAt=0,{},oDp:aDefault[nAt,2])

   FOR I=1 TO LEN(aDefault)

      IF oFrm:IsDef(aDefault[I,1])

         uValue:=oFrm:Get(aDefault[I,1])
         cType :=ValType(uValue) 
       
         // aDefault[I,3] es CAM_UPDATE


         IF (Empty(uValue) .OR. cType="L") .OR. aDefault[I,3]

            uValue:=aDefault[I,2]

            IF LEFT(uValue,1)="&" 
             uValue:=MACROEJE(uValue)
            ELSE
             uValue:=STRTRAN(uValue,["],[])
             uValue:=CTOO(uValue,cType)
            ENDIF

            oFrm:Set(aDefault[I,1],uValue)

         ENDIF

      ENDIF

   NEXT I

   nAt  :=ASCAN(oDp:aFieldZero,{|a,n| a[1]=cTable })
   aZero:=IF(nAt=0,{},oDp:aFieldZero[nAt,2])

   FOR I=1 TO LEN(aZero)

     IF oFrm:IsDef(aZero[I,1]) .AND. ValType(oFrm:Get(aZero[I,1]))="C"

        uValue:=ALLTRIM(oFrm:Get(aZero[I,1]))

        IF !Empty(uValue) 
           uValue:=REPLI("0",aZero[I,2]-LEN(uValue))+uValue
           oFrm:Set(aZero[I,1],uValue)
        ENDIF
       
     ENDIF

   NEXT I

RETURN .T.
// EOF
