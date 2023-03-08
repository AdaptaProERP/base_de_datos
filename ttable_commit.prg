// Programa   : TTABLE_COMMIT
// Fecha/Hora : 07/01/2017 15:48:29
// Propósito  : Corregir o Alinear Comando INSERT o UPDATE 
// Creado Por : Juan Navas
// Llamado por: CLASE TTABLE/METHOD COMMIT Antes de oDb:Execute(cSql)
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cSql,oDb,cType,oTable)
  LOCAL aDefault:={},cTable,I,cField,uValue,cType
  LOCAL cFile,cDir,nAt,cProg

  oDp:cSqlCommit:=cSql
  
  // JN, Guardar en Disco la traza de Sentencias SQL
  DEFAULT oDp:lSaveSqlFile   :=.T.,;
          oDp:aFieldUpdateDpX:={}

  DEFAULT oTable:=OpenTable("SELECT * FROM DPMOVINV LIMIT 1",.T.)
  
  cTable  :=ALLTRIM(oTable:cTable)

  // aDefault:=EJECUTAR("GETDEFAULT",cTable)
  // Director segun la BD

  cDir :="query_"+oTable:oOdbc:cName
  cFile:=cDir+"\"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")+"_"+cTable+".SQL"

  lMkDir(cDir)

  IF oDp:lSaveSqlFile
    DPWRITE(cFile,cSql)
  ENDIF
  
RETURN cSql
// EOF
