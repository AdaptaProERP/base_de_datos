// Programa   : INSERTRECORD
// Fecha/Hora : 15/11/2015 22:05:10
// Propósito  : Crear Registro y Autocrear Vinculos (Recuperación de Integridad referencial
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,aFields,aValues,lLink)
   LOCAL cValues:={},I,nAt,uValue,nAt1,nAt2,U,n,aLinks:={},oData
   LOCAL aLink,cWhere,aWhere,aValue,oTable,aNombre:={"_TITULO","_DESCRI","_NOMBRE"}
   LOCAL aFieldL:={} // Campos del Enlace DPLINK, Esta concatenados
   LOCAL aFieldO:={} // Campos Originales
   LOCAL aInsert:={} // Arreglo de Inserción
   LOCAL aData  :={} // Datos
   LOCAL aFieldX:={} // Campos en el Orden del Where

   DEFAULT cTable :="DPPROGRA",;
           aFields:={"PRG_CODIGO","PRG_DESCRI","PRG_TEXTO"},;
           aValues:={"NULO"      ,"00001"     ,"MEMO"    }


   DEFAULT lLink:=.T.

   IF ValType(aFields)="C"

      IF ","$aFields
        aFields:=_VECTOR(aFields)
      ELSE
        aFields:={aFields}
      ENDIF

   ENDIF

   IF ValType(aValues)="C"
      aValues:={aValues}
   ENDIF

   IF Empty(aFields)
      MensajeErr("Requiere Parámetros Cambio")
      RETURN {}
   ENDIF

   oTable:=OpenTable("SELECT * FROM "+cTable,.F.)

   IF lLink
     oTable:End()
   ENDIF

   // oTable:AppendBlank()
   IF oTable=NIL
      MensajeErr("Tabla "+cTable+" no pudo ser Abierta")
      oTable:End()
      RETURN {}
   ENDIF

   IF oTable:FieldPos(aFields[1])=0
      MensajeErr("Campo "+aFields[1]+" no existe en Tabla "+cTable+" Programa INSERTRECORD ")
      oTable:End()
      RETURN {}
   ENDIF

   FOR I=1 TO LEN(aFields)

     aFields[I]:=ALLTRIM(aFields[I])

     IF ValType(oTable:FieldGet(aFields[I]))="C" .AND. ValType(aValues[I])="C"
       aValues[I]:=LEFT(aValues[I],LEN(oTable:FieldGet(aFields[I])))
     ENDIF

     // Busca los datos por Campo
     oTable:Replace(aFields[I],aValues[I])
   
   NEXT 

   // Agrega los campos y valores faltantes desde Parametros
   IF lLink

      AEVAL(oTable:aFields,{|a,n,nAt| nAt:=ASCAN(aFields,ALLTRIM(a[1])),;
                                      IF(nAt=0,AADD(aFields,a[1]),NIL),;
                                      IF(nAt=0,AADD(aValues,oTable:FieldGet(n)),NIL) })

      EJECUTAR("DPTABLESETDEF",oTable,.F.)

      // Prepara Arreglo 
      FOR I=1 TO LEN(aFields)
        aFields[I]:={ALLTRIM(aFields[I]),aValues[I],"","","",""}
      NEXT I

   ELSE

     // JN 8/3/2023, debe insertar registros sin validación de Integridad
     oTable:EXECUTE("SET FOREIGN_KEY_CHECKS = 0")
     AEVAL(aFields,{|a,n| oTable:Replace(aFields[n],aValues[n])})
     oTable:Commit()
     oTable:End()

     RETURN {}

   ENDIF

   DEFAULT oDp:aLinkInsert:={}

   cTable :=ALLTRIM(cTable)
   nAt    :=ASCAN(oDp:aLinkInsert,{|a,n| a[1]==cTable})

   IF nAt>0

      aLink:=oDp:aLinkInsert[nAt,2]

   ELSE

   
      aLink  :=ASQL("SELECT LNK_TABLES,LNK_FIELDS,LNK_FIELDD FROM DPLINK WHERE LNK_TABLED"+GetWhere("=",cTable)+;
                    " AND LNK_RUN=1 AND LNK_VIRTUA=0 "+;
                    " GROUP BY LNK_TABLES,LNK_FIELDS,LNK_FIELDD ")

      AADD(oDp:aLinkInsert,{cTable,ACLONE(aLink)})

   ENDIF

   aLinks :=ACLONE(aLink)

   // Integridad referencia desactivada 07/03/2023
   IF !lLink
      aLinks:={}
   ENDIF

   // Busca todos los Vinculos

   FOR n=1 TO LEN(aLink)

     aFieldL:=_VECTOR(aLink[n,2])
     aFieldO:=_VECTOR(aLink[n,3])
     AEVAL(aFieldO,{|a,n|aFieldO[n]:=ALLTRIM(a)})
     AEVAL(aFieldL,{|a,n|aFieldL[n]:=ALLTRIM(a)})

    // Buscar en la Tabla si el Registro existe
     cWhere :=""
     aData  :={}
     aFieldX:={}

     FOR I=1 TO LEN(aFields)

      nAt   :=ASCAN(aFieldO,{|a,n| ALLTRIM(aFields[I,1])==ALLTRIM(a) }) // Busca solo los campos del Indice
    
      IF nAt>0

         AADD(aData,oTable:FieldGet(aFields[I,1])) // aValues[I])

         cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+aFieldL[nAt]+GetWhere("=",oTable:FieldGet(aFields[I,1]))

         AADD(aFieldX,aFieldL[nAt])

      ENDIF

     NEXTI

     oDp:lExcluye:=.F.
     oData:=OpenTable("SELECT "+ALLTRIM(aLink[n,2])+" FROM "+ALLTRIM(aLink[n,1]) +" WHERE "+cWhere+" LIMIT 1",.T.)

     IF oData:RecCount()=0
       AADD(aInsert,{aLink[n,1],ACLONE(aFieldX),ACLONE(aData),cWhere})
     ENDIF

     oData:End()
   
   NEXT n

   FOR I=1 TO LEN(aInsert)

     cTable :=aInsert[I,1]
     oTable :=OpenTable("SELECT * FROM "+cTable,.F.)
     aFields:=ACLONE(aInsert[I,2])
     aData  :=ACLONE(aInsert[I,3])
     oTable:AppendBlank()

     AEVAL(aFields,{|a,n| oTable:Replace(a,aData[n])})
     oTable:IsChkIntRef(.F.) // Ejecuta Programa CHKINTREF, para insertar registros segun campos sin vínculos.
     oTable:Commit()
     oTable:End()

   NEXT I

   IF Empty(aInsert)
      oTable:Commit()
   ENDIF

   oTable:End()

RETURN aInsert
// EOF
