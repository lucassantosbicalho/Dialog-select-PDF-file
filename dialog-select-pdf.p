/*------------------------------------------------------------------------------
 Purpose: Open dialog to save PDF file in a BLOB field on database
 Author: Lucas Bicalho
 Creation: 2022-11-23
------------------------------------------------------------------------------*/
    DEFINE BUTTON btOk                 LABEL "&OK"      SIZE 14 BY 1.
    DEFINE BUTTON btCancel             LABEL "&Cancel"  SIZE 14 BY 1.

    DEFINE VARIABLE cInfo              AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE dDate              AS DATE                      NO-UNDO.
    DEFINE VARIABLE cUser              AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE intSeq             AS INTEGER                   NO-UNDO.
    DEFINE VARIABLE cTitle             AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE cFile              AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE cFileTemp          AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE cDocType           AS CHARACTER                 NO-UNDO. 
    DEFINE VARIABLE cbDocType          AS CHARACTER 
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEM-PAIRS "Choose one", "",
                     "Category 1", 1,
                     "Category 2", 2,
                     "Category 3", 3,
                     "Category 4", 4,
                     "Category 5", 5,
                     "Category 6", 6
     LABEL "Document type"
     INITIAL 1
     NO-UNDO.
    
    cDocType = "".
    dDate = TODAY.
    cUser = "user1". // Handle to get the logged user at your application
    cInfo = "Add PDF file. Save it at your database".     
    /* --- ---*/
    DEFINE BUTTON btAddFile 
    LABEL "+" 
    SIZE 4.0 BY 1.2.
        
    &GLOBAL-DEFINE colon01 COLON 10
               
    DEFINE FRAME frAddFile SKIP(0.5)

        
        cInfo                   NO-LABEL
                                VIEW-AS TEXT
                                AT ROW 2 COL 22 FORMAT "X(40)" SKIP
                                                                         
        dDate                   LABEL "Date" FORMAT "99/99/9999"         
                                VIEW-AS FILL-IN SIZE 20 BY 1             
                                AT ROW 4.20 COL 14.0                      SKIP
                                                                         
        cUser                   LABEL "User" FORMAT "X(25)"           
                                VIEW-AS FILL-IN SIZE 20 BY 1             
                                AT ROW 5.30 COL 13.8                      SKIP
                                                                         
        cbDocType               AT ROW 6.40 COL 4.3                       SKIP                                         
                                                                         
        cFile                   LABEL "File" FORMAT "X(60)"           
                                VIEW-AS FILL-IN SIZE 50.3 BY 1           
                                AT ROW 7.50 COL 14.68                     SKIP
                                                                         
        btAddFile               AT ROW 7.35 COL 70.5                                                 
                                                                         
        cTitle                  LABEL "Title" FORMAT "X(40)"         
                                VIEW-AS EDITOR SIZE 54.5 BY 1              
                                AT ROW 8.60 COL 14.22                     SKIP(2)

        btOk           AT 25 SPACE(5)
        btCancel      SKIP(0.5)
        WITH CENTERED ATTR-SPACE SIDE-LABELS OVERLAY VIEW-AS DIALOG-BOX THREE-D BGCOLOR 8
        WIDTH 80 KEEP-TAB-ORDER TITLE " Inclusao de arquivo pdf ".
    /* --- ---*/    
    ON CHOOSE OF btAddFile DO: 
        RUN prSelectFile(OUTPUT cFileTemp).
        cFile = SUBSTRING(cFileTemp, R-INDEX(cFileTemp, "/" ) + 1 ).
        IF LENGTH(cFile) = LENGTH(cFileTemp)
            THEN cFile = SUBSTRING(cFile, R-INDEX(cFile, "\" ) + 1 ). 
        cFile = REPLACE(cFile, " ", "").
        DISPLAY cFile WITH FRAME frAddFile.
    END.
    /* --- ---*/
    ON GO OF FRAME frAddFile DO: 
       APPLY "CHOOSE" TO btOk IN FRAME frAddFile. 
    END.
    /* --- ---*/
    ON WINDOW-CLOSE OF FRAME frAddFile DO:
       APPLY "CHOOSE" TO btCancel IN FRAME frAddFile.
       RETURN NO-APPLY.
    END.
    /* --- ---*/
    ON CHOOSE OF btOk IN FRAME frAddFile DO:
        /* --- ---*/
        ASSIGN dDate cUser cbDocType cFile cTitle.
        /* --- ---*/
        IF cbDocType = "" THEN DO:
            MESSAGE "Document type required!":U VIEW-AS ALERT-BOX ERROR TITLE "Atention!".
            RETURN NO-APPLY.
        END.
        
        IF LENGTH (cFile) < 1 THEN DO:
            MESSAGE "Choose a .pdf file!":U VIEW-AS ALERT-BOX ERROR TITLE "Atention!".
            RETURN NO-APPLY.
        END.

        IF LENGTH (cTitle) < 1 THEN DO:
            MESSAGE "Title required!":U VIEW-AS ALERT-BOX ERROR TITLE "Atention!".
            RETURN NO-APPLY.
        END.
        
        cDocType = ENTRY(LOOKUP(cbDocType:SCREEN-VALUE, cbDocType:LIST-ITEM-PAIRS) - 1, cbDocType:LIST-ITEM-PAIRS).
        /* --- ---*/
        /*
            // TO WRITE THE CONTENT FILE IN A DATABASE TABLE FIELD, USE THE COPY-LOB COMMAND
            // ASSUME YOUR ESTRUCTURE has a table 'tableB' in a database 'dbA' with a BLOB field 'blob_field'

            COPY-LOB FILE cFileTemp TO dbA.tableB.blob_field.

            DISPLAYING VALUES JUST TO FINISH THIS EXAMPLE
        */
            MESSAGE "Date:" dDate SKIP "User:" cUser SKIP "Doc type:" cbDocType SKIP "File:" cFile SKIP "Title:" cTitle 
            VIEW-AS ALERT-BOX INFORMATION TITLE "Info!".
            

        /* --- ---*/
                            
    END.
    /* --- ---*/
    ENABLE ALL EXCEPT cInfo dDate cUser cFile WITH FRAME frAddFile.
    /* --- ---*/
    DISPLAY cInfo dDate cUser cbDocType cFile cTitle WITH FRAME frAddFile.
    /* --- ---*/
    APPLY "ENTRY" TO cbDocType IN FRAME frAddFile.
    /* --- ---*/
    WAIT-FOR CHOOSE OF btOk, btCancel IN FRAME frAddFile.


PROCEDURE prSelectFile :
/*------------------------------------------------------------------------------
 Purpose: Open dialog box to select a .pdf file
 Notes: Based on https://knowledgebase.progress.com/articles/Article/000032924
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER procname    AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE         OKpressed   AS LOGICAL   NO-UNDO INITIAL TRUE. 

    SYSTEM-DIALOG GET-FILE procname 
    TITLE "Choose PDF file" 
    FILTERS "Source Files (*.pdf)" "*.pdf" 
    MUST-EXIST 
    USE-FILENAME 
    UPDATE OKpressed. 

END PROCEDURE.
