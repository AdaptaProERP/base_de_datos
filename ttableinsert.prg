// Programa   : TTABLEINSERT
// Fecha/Hora : 17/03/2011 14:27:14
// Propósito  : Ejecución Previa TABLE:COMMIT() , Clausula INSERT INTO
// Creado Por : Juan Navas
// Llamado por: TTABLE:COMMIT()
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oTable)
  LOCAL nAt,cField,I,cTable,uValue,aDefault,cType,cProg

  DEFAULT oDp:aInsertDef     :={},;
          oDp:aFieldUpdateDpX:={}

  IF Empty(oDp:aInsertDef)
     oDp:aInsertDef:=ASQL([SELECT RTRIM(CAM_TABLE),RTRIM(CAM_NAME),RTRIM(CAM_DEFAUL) FROM DPCAMPOS WHERE CAM_DEFAUL<>""])
  ENDIF

  cTable:=ALLTRIM(oTable:cTable)

  aDefault:=EJECUTAR("GETDEFAULT",cTable)

/*
  FOR I=1 TO LEN(oDp:aInsertDef)

    IF oDp:aInsertDef[I,1]==cTable

       cField:=oDp:aInsertDef[I,2]

       IF Empty(oTable:FieldGet(cField))
         uValue:=oDp:aInsertDef[I,3]
         oTable:Replace(cField,uValue)
       ENDIF

    ENDIF

  NEXT I
*/

  // 22/12/2022

  FOR I=1 TO LEN(aDefault)

     cField:=aDefault[I,1]
     uValue:=NIL

     IF oTable:FieldPos(cField)>0
        uValue:=oTable:FieldGet(cField)
     ENDIF

     IF Empty(uValue) .AND. oTable:FieldPos(cField)>0

         cType :=ValType(uValue)
         uValue:=aDefault[I,2]

         IF  LEFT(uValue,1)="&" .OR. ("("$uValue  .AND. ["]$uValue)

            uValue:=MACROEJE(uValue)

         ELSE

           IF !["]$uValue
             uValue:=CTOO(uValue,cType)
           ENDIF

         ENDIF

         // Caracteres "Indefinidos" debe ser Indefinido
         IF ValType(uValue)="C" .AND. LEFT(uValue,1)=["]
            uValue:=MACROEJE(uValue)
         ENDIF


         oTable:Replace(cField,uValue)

     ENDIF

  NEXT I

  // oDp:oFrameDp:SetText(cTable+" TTABLEINSERT")
  nAt:=ASCAN(oDp:aFieldUpdateDpX,{|a,n| cTable==a[1]})

  IF nAt>0

    // FOR I=1 TO LEN(oTable:aFields)
    FOR I=1 TO LEN(oDp:aFieldUpdateDpX)

     IF oDp:aFieldUpdateDpX[I,1]==cTable

       cField:=oDp:aFieldUpdateDpX[I,2]  //ALLTRIM(oTable:aFields[I,1])
       // nAt   :=ASCAN(oDp:aFieldUpdateDpX,{|a,n| cTable==a[1] .AND. cField==a[2]})
       uValue:=oTable:FieldGet(cField)

       // IF(nAt>0,oTable:FieldGet(I),NIL)

       IF nAt>0 .AND. Empty(uValue)
          cProg :=oDp:aFieldUpdateDpX[nAt,3]
          uValue:=MACROEJE(cProg)
          oTable:Replace(cField,uValue)
       ENDIF

     ENDIF

    NEXT I

  ENDIF


RETURN .T.
// EOF
