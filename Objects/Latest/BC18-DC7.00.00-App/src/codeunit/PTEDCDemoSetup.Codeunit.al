codeunit 63010 "PTE DC Demo Setup"
{
    // Codeunit, welches die CDC Demoumgebung zurücksetzen kann
    trigger OnRun()
    var
        DemoSetup: Record "DCADV DC Demo Setup";
    begin
        if not Confirm(Text001, false) then
            Error('Zurücksetzen wurde abgebrochen, es wurden keine Daten geändert!');

        if not DemoSetup.Get then
            error('You have not setup the demo app and therefor cannot reset the data.');

        //Ungebuchte Belege löschen
        if DemoSetup."Reset Posting Entries" then begin
            if (DemoSetup."Value Entry No." = 0) or (DemoSetup."Det. Vend. Ledg. Entry No." = 0) then
                Error('You have not configured the posting entries that shouldn''t be deleted!');
            DeleteEntries();
        end;

        DeleteDocuments();

        // Posten löschen/aufräumen
        if DemoSetup."Reset Posting Entries" then begin
            DeleteEntries();
            CreatePurchaseOrders();
            PostShipmentOfPurchaseOrders;
        end;

        if DemoSetup."Delete absence sh. approvals" then
            DeleteAbsenceSharedApprovals();


        DeleteRecordIDTree();
        DeleteTemplates();
        DeleteApprovalEntries();
        ResetVendors();

        // Get new documents
        UpdateDemoDocuments();

        //Prepare Demo
        PrepareDemo();

        // Verkauf
        DeleteSalesOrders();
        CreateItemCrossRef();
        RenameFieldNames();

        // GL/Entry
        //GLEntryPrepareCompany;

        // Export document categories
        REPORT.Run(REPORT::"CDC Export OCR Config. Files", false, false);

        Message(Text002);
    end;

    var
        Text001: Label 'Soll die Demo-Umgebung wirklich zurückgesetzt werden?';
        Text002: Label 'Die Demo-Umgebung wurde erfolgreich zurückgesetzt!';
        lDocument: Record "CDC Document";

    local procedure DeleteEntries()
    var
        DemoSetup: Record "DCADV DC Demo Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchDocMatch: Record "CDC Purch. Doc. Match";
        PurchaseLineRelationship: Record "CDC Purchase Line Relationship";
        lPurchInvHeader: Record "Purch. Inv. Header";
        lPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        lPurchRcptHeader: Record "Purch. Rcpt. Header";
        lPurchRcptLine: Record "Purch. Rcpt. Line";
        lVendLedgEntry: Record "Vendor Ledger Entry";
        lDetVendLedgeEntry: Record "Detailed Vendor Ledg. Entry";
        lGLEntry: Record "G/L Entry";
        lGlVatEntryLink: Record "G/L Entry - VAT Entry Link";
        lCustLedgeEntry: Record "Cust. Ledger Entry";
        lDetCustLedgeEntry: Record "Detailed Cust. Ledg. Entry";
        lItemLedgerEntry: Record "Item Ledger Entry";
        lVatEntry: Record "VAT Entry";
        lItemApplEntry: Record "Item Application Entry";
        lValueEntry: Record "Value Entry";
        lPostValueEntryToGlEntry: Record "Post Value Entry to G/L";
    begin
        DemoSetup.Get;

        // Delete posted shipments >>>
        lPurchRcptHeader.SetFilter("No.", '>%1', DemoSetup."Purch. Rcpt. Header No.");
        if lPurchRcptHeader.Find('-') then
            repeat
                lPurchRcptLine.SetRange("Document No.", lPurchRcptHeader."No.");
                lPurchRcptLine.DeleteAll;
            until lPurchRcptHeader.Next = 0;
        lPurchRcptHeader.DeleteAll(true);
        // Delete posted shipments <<<

        // DeletePostedInvoices >>>
        lPurchInvHeader.SetFilter("No.", '>%1', DemoSetup."Purch. Inv. Header No.");
        lPurchInvHeader.DeleteAll(true);
        // DeletePostedInvoices <<<

        // DeletePostedCr. Memos>>>
        lPurchCrMemoHeader.SetFilter("No.", '>%1', DemoSetup."Purch. Cr. Memo Header No.");
        lPurchCrMemoHeader.DeleteAll(true);
        // DeletePostedCr. Memos <<<

        // Delete demo purch. orders >>>
        PurchDocMatch.DeleteAll(true);
        PurchaseLineRelationship.DeleteAll(true);

        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", DemoSetup."Purch Order No. From", DemoSetup."Purch Order No. To");
        if not PurchaseLine.IsEmpty then
            PurchaseLine.DeleteAll;

        PurchaseHeader.Reset;
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("No.", DemoSetup."Purch Order No. From", DemoSetup."Purch Order No. To");
        if not PurchaseHeader.IsEmpty then
            PurchaseHeader.DeleteAll;
        // Delete demo purch. orders <<<

        // Delete unposted Purch Invoices >>>
        PurchaseHeader.Reset;
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.DeleteAll(true);
        // Delete unposted Purch Invoices <<<

        // Delete unposted Purch Cr. Memo >>>
        PurchaseHeader.Reset;
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseHeader.DeleteAll(true);
        // Delete unposted Purch Cr. Memo<<<

        // Delte other entries
        lGLEntry.SetFilter("Entry No.", '>%1', DemoSetup."G/L Entry No.");
        lGLEntry.DeleteAll(true);

        lGlVatEntryLink.SetFilter("G/L Entry No.", '>%1', DemoSetup."G/L VAT Entry Link No.");
        lGlVatEntryLink.DeleteAll(true);

        lCustLedgeEntry.SetFilter("Entry No.", '>%1', DemoSetup."Cust. Ledge Entry No.");
        lCustLedgeEntry.DeleteAll(true);

        lDetCustLedgeEntry.SetFilter("Entry No.", '>%1', DemoSetup."Det. Cust. Ledge Entry No.");
        lDetCustLedgeEntry.DeleteAll(true);

        lItemLedgerEntry.SetFilter("Entry No.", '>%1', DemoSetup."Item Ledge. Entry No.");
        lItemLedgerEntry.DeleteAll(true);

        lVatEntry.SetFilter("Entry No.", '>%1', DemoSetup."Vat Entry No.");
        lVatEntry.DeleteAll(true);

        lItemApplEntry.SetFilter("Entry No.", '>%1', DemoSetup."Item Appl. Entry No.");
        lItemApplEntry.DeleteAll(true);

        lVendLedgEntry.Reset;
        lVendLedgEntry.SetFilter("Entry No.", '>%1', DemoSetup."Vend. Ledg. Entry No.");
        lVendLedgEntry.DeleteAll;

        lDetVendLedgeEntry.Reset;
        lDetVendLedgeEntry.SetFilter("Entry No.", '>%1', DemoSetup."Det. Vend. Ledg. Entry No.");
        lDetVendLedgeEntry.DeleteAll(true);

        lValueEntry.SetFilter("Entry No.", '>%1', DemoSetup."Value Entry No.");
        lValueEntry.DeleteAll(true);

        lPostValueEntryToGlEntry.SetFilter("Value Entry No.", '>%1', DemoSetup."Post. Value to GL Entry No.");
        lPostValueEntryToGlEntry.DeleteAll(true);
    end;

    procedure SelectDemoTemplateLanguage()
    var
        DemoSetup: Record "DCADV DC Demo Setup";
        LanguageBuffer: Record Language temporary;
        Http: Codeunit "CSC Http";

        XmlDoc: Codeunit "CSC XML Document";
        DocumentElement: Codeunit "CSC XML Node";
        Languages: Codeunit "CSC XML NodeList";
        LanguageNode: Codeunit "CSC XML Node";
        i: Integer;
        NoLanguagesFoundErrorMsg: Label 'No valid languages found from master configration link:\%1', Locked = true;
    begin
        // download master configuration
        DemoSetup.Get();
        DemoSetup.TestField("Template Master  Path");
        Http.GetDocument(StrSubstNo('%1/master.config.xml', GetCleanTemplateMasterPath()), true, XmlDoc);
        if Http.GetStatusCode() = 200 then begin
            XmlDoc.GetDocumentElement(DocumentElement);
            DocumentElement.SelectNodes(Languages, 'Language');
            // write online available languages to buffer
            for i := 0 to Languages.Count() - 1 do begin
                Languages.GetItem(LanguageNode, i);
                LanguageBuffer.Code := LanguageNode.GetNodeAttribAsText('Code');
                LanguageBuffer.Name := LanguageNode.GetNodeAttribAsText('Description');
                if not LanguageBuffer.Insert() then;
                LanguageBuffer.Modify();
            end;
        end else begin
            Error('Error: %1', Http.GetStatusCode());
        end;

        // let user select from language buffer
        if LanguageBuffer.Count = 0 then
            Error(NoLanguagesFoundErrorMsg, DemoSetup."Template Master  Path");

        if Page.RunModal(Page::Languages, LanguageBuffer) = Action::LookupOK then begin
            DemoSetup."Template Language" := LowerCase(LanguageBuffer.Code);
            DemoSetup.Modify();
        end;
    end;

    local procedure GetCleanTemplateMasterPath(): Text
    var
        DemoSetup: Record "DCADV DC Demo Setup";
    begin
        if not DemoSetup.Get() then
            exit;
        exit(DelChr(DemoSetup."Template Master  Path", '>', '/'));
    end;

    local procedure UpdateDemoDocuments()
    var
        DemoDocuments: Record "DCADV DC Demo Document";
        TempFile: Record "CDC Temp File" temporary;
        DocCat: Record "CDC Document Category";
        DocPath: Text;
        TempFileStorage: Codeunit "CDC Temp File Storage";
        DocumentImporter: Codeunit "CDC Document Importer";
    begin
        if DemoDocuments.FindFirst() then
            repeat
                if (DocCat.Get(DemoDocuments."Document Category")) then begin
                    if (DemoDocuments."File Type" = DemoDocuments."File Type"::pdf) then begin
                        DocPath := DocCat.GetCategoryPath(2);
                        DemoDocuments.CalcFields("Pdf Content", "Tiff Content", "Png Content", "OCR Content", "XML Content");

                        // pdf 
                        Clear(TempFile);
                        TempFile.Name := StrSubstNo('CO-%1.%2', DemoDocuments."Document No.", 'pdf');
                        TempFile.Path := DocPath;
                        TempFile.Data := DemoDocuments."Pdf Content";
                        TempFileStorage.AddFile(TempFile);

                        // tiff
                        Clear(TempFile);
                        TempFile.Name := StrSubstNo('CO-%1.%2', DemoDocuments."Document No.", 'tiff');
                        TempFile.Path := DocPath;
                        TempFile.Data := DemoDocuments."Tiff Content";
                        TempFileStorage.AddFile(TempFile);

                        // png
                        Clear(TempFile);
                        TempFile.Name := StrSubstNo('CO-%1-pages.%2', DemoDocuments."Document No.", 'xml');
                        TempFile.Path := DocPath;
                        TempFile.Data := DemoDocuments."Png Content";
                        TempFileStorage.AddFile(TempFile);

                        // ocr
                        Clear(TempFile);
                        TempFile.Name := StrSubstNo('CO-%1.%2', DemoDocuments."Document No.", 'xml');
                        TempFile.Path := DocPath;
                        TempFile.Data := DemoDocuments."OCR Content";
                        TempFileStorage.AddFile(TempFile);
                    end else begin
                        DocPath := DocCat.GetCategoryPath(4);
                        DemoDocuments.CalcFields("XML Content");

                        // e-invoice 
                        Clear(TempFile);
                        TempFile.Name := StrSubstNo('CO-%1.%2', DemoDocuments."Document No.", 'xml');
                        TempFile.Path := DocPath;
                        TempFile.Data := DemoDocuments."Xml Content";
                        TempFileStorage.AddFile(TempFile);
                    end;
                end;
            until DemoDocuments.Next() = 0;
        DocumentImporter.Run();
    end;

    internal procedure DownloadDemoDocuments(): Boolean
    var
        DemoSetup: Record "DCADV DC Demo Setup";
        Http: Codeunit "CSC Http";
        XmlDoc: Codeunit "CSC XML Document";
        DocumentElement: Codeunit "CSC XML Node";
        Documents: Codeunit "CSC XML NodeList";
        DocumentNode: Codeunit "CSC XML Node";
        DocumentChildNodes: Codeunit "CSC XML NodeList";
        i: Integer;
        FromUrl: Text;
        DownloadInfoMessage: Label '%1 documents have been downloaded.';
    begin
        DemoSetup.Get();
        if (DemoSetup."Template Language" = '') or (DemoSetup."Template Master  Path" = '') then
            exit(false);

        // Build main url 
        FromUrl := StrSubstNo('%1/%2/', GetCleanTemplateMasterPath(), DemoSetup."Template Language");

        // Download language configuration
        Http.GetDocument(StrSubstNo('%1/%2.config.xml', FromUrl, DemoSetup."Template Language"), true, XmlDoc);
        if Http.GetStatusCode() = 200 then begin
            XmlDoc.GetDocumentElement(DocumentElement);
            DocumentElement.SelectNodes(Documents, 'Document');

            // Iterate through demo document nodes of selected language
            for i := 0 to Documents.Count() - 1 do begin
                // get current demo document item
                Documents.GetItem(DocumentNode, i);
                DocumentNode.GetChildNodes(DocumentChildNodes);

                // download demo document parts
                DownloadDemoDocument(DocumentNode, FromUrl);
            end;

            // Finally import 
            //DocumentImporter.Run();
            Message(DownloadInfoMessage, Documents.Count);
            exit(true);
        end else begin
            Error('Error: %1', Http.GetStatusCode());
        end;

    end;

    local procedure DownloadDemoDocument(DocumentNode: Codeunit "CSC XML Node"; FromUrl: Text)
    var
        DemoDocument: Record "DCADV DC Demo Document";
        DocCat: Record "CDC Document Category";
        Http: Codeunit "CSC Http";
        WriteStream: OutStream;
        DocumentChildNodes: Codeunit "CSC XML NodeList";
        TempNode: Codeunit "CSC XML Node";
        i: Integer;
    begin
        // get child nodes of current document
        DocumentNode.GetChildNodes(DocumentChildNodes);

        if (DocumentChildNodes.Count() > 0) then begin
            // remove existing demo document
            if DemoDocument.Get(DocumentNode.GetNodeAttribAsText('DocumentNo')) then
                DemoDocument.Delete();

            Clear(DemoDocument);
            DemoDocument.Validate("Document No.", DocumentNode.GetNodeAttribAsText('DocumentNo'));
            DemoDocument.Validate(Description, DocumentNode.GetNodeAttribAsText('Description'));
            case DocumentNode.GetNodeAttribAsText('Type') of
                'pdf':
                    DemoDocument.Validate("File Type", DemoDocument."File Type"::pdf);
                'xml':
                    DemoDocument.Validate("File Type", DemoDocument."File Type"::xml);
            end;

            if DocCat.Get(DocumentNode.GetNodeAttribAsText('Category')) then
                DemoDocument.Validate("Document Category", DocCat.Code);
            DemoDocument.Insert(true);

            for i := 0 to DocumentChildNodes.Count() do begin
                DocumentChildNodes.GetItem(TempNode, i);
                clear(WriteStream);
                case (TempNode.GetName()) of
                    'pdf':
                        DemoDocument."Pdf Content".CREATEOUTSTREAM(WriteStream);
                    'tiff':
                        DemoDocument."Tiff Content".CREATEOUTSTREAM(WriteStream);
                    'words':
                        DemoDocument."OCR Content".CREATEOUTSTREAM(WriteStream);
                    'png':
                        DemoDocument."Png Content".CREATEOUTSTREAM(WriteStream);
                    'xml':
                        DemoDocument."Xml Content".CREATEOUTSTREAM(WriteStream);
                end;
                Http.DownloadToStream(StrSubstNo('%1/%2', FromUrl, TempNode.InnerText()), WriteStream);
            end;
            DemoDocument.Modify();
        end
    end;


    local procedure DownloadFile(FromUrl: Text[1024]; ToFilePath: Text[1024]; ToFileName: Text[1024]; var TempFile: Record "CDC Temp File" temporary)
    var
        Http: Codeunit "CSC Http";
        WriteStream: OutStream;
    begin
        CLEAR(TempFile);

        TempFile.Data.CREATEOUTSTREAM(WriteStream);
        Http.DownloadToStream(FromUrl, WriteStream);
    end;




    local procedure DeleteTemplates()
    var
        lTemplate: Record "CDC Template";
        lField: Record "CDC Template Field";
        lDataTransl: Record "CDC Data Translation";
        lSearchText: Record "CDC Template Search Text";
        lNoSeriesLine: Record "No. Series Line";
    begin
        lTemplate.SetRange(Type, lTemplate.Type::" ");
        if lTemplate.FindSet then
            repeat
                lDataTransl.SetRange("Template No.", lTemplate."No.");
                lDataTransl.DeleteAll(true);

                lField.SetRange("Template No.", lTemplate."No.");
                lField.DeleteAll(true);

                lSearchText.SetRange("Template No.", lTemplate."No.");
                lSearchText.DeleteAll(true);
            until lTemplate.Next = 0;

        lTemplate.DeleteAll(true);

        //Nummernserien zurücksetzen
        if lNoSeriesLine.Get('DC-TEMPL', 10000) then begin
            lNoSeriesLine."Last No. Used" := '';
            lNoSeriesLine."Last Date Used" := 0D;
            lNoSeriesLine.Modify;
        end;

        if lNoSeriesLine.Get('DC-DOC', 10000) then begin
            lNoSeriesLine."Last No. Used" := '';
            lNoSeriesLine."Last Date Used" := 0D;
            lNoSeriesLine.Modify;
        end;

        if lNoSeriesLine.Get('V-AUFTR-1', 10000) then begin
            lNoSeriesLine."Last No. Used" := '';
            lNoSeriesLine."Last Date Used" := 0D;
            lNoSeriesLine.Modify;
        end;
    end;

    local procedure DeleteDocuments()
    var
        lDocument: Record "CDC Document";
    begin
        lDocument.ModifyAll(Status, lDocument.Status::Open);
        lDocument.ModifyAll("Allow Delete", false);
        lDocument.DeleteAll(true);
    end;

    local procedure DeleteRecordIDTree()
    var
        lRecIdTree: Record "CDC Record ID Tree";
    begin
        lRecIdTree.DeleteAll(true);
    end;

    local procedure DeleteApprovalEntries()
    var
        lApprovalEntry: Record "Approval Entry";
        lApprovalCommentLine: Record "Approval Comment Line";
        lPostedApprovalEntry: Record "Posted Approval Entry";
        lPostedApprovalCommentLine: Record "Posted Approval Comment Line";
        lOverdueApprovalEntry: Record "Overdue Approval Entry";
    begin
        lApprovalCommentLine.DeleteAll(true);
        lApprovalEntry.DeleteAll(true);
        lPostedApprovalCommentLine.DeleteAll(true);
        lPostedApprovalEntry.DeleteAll(true);
        lOverdueApprovalEntry.DeleteAll(true);
    end;

    local procedure ResetVendors()
    var
        lVendor: Record Vendor;
    begin
        lVendor.Get('61000');
        lVendor.Validate("Location Code", '');
        lVendor.Modify(true);
    end;

    local procedure CreatePurchaseOrders()
    var
        lFromPurchHeader: Record "Purchase Header";
        lToPurchHeader: Record "Purchase Header";
        lToPurchLine: Record "Purchase Line";
        lPurchRcptHeader: Record "Purch. Rcpt. Header";
        lPurchRcptLine: Record "Purch. Rcpt. Line";
        lCopyDocMgt: Codeunit "Copy Document Mgt.";
        purchDocTypes: Enum "Purchase Document Type From";
    begin
        // Create base documents first
        CreateDemoDocuments();

        lToPurchLine.SetRange("Document Type", lToPurchLine."Document Type"::Order);
        lToPurchLine.SetRange("Document No.", '1003', '1005');
        if not lToPurchLine.IsEmpty then
            lToPurchLine.ModifyAll("Qty. Rcd. Not Invoiced", 0);

        lToPurchHeader.SetRange("Document Type", lToPurchHeader."Document Type"::Order);
        lToPurchHeader.SetRange("No.", '1003', '1005');
        if lToPurchHeader.FindFirst then
            lToPurchHeader.Delete(true);

        Clear(lToPurchHeader);
        lToPurchHeader."Document Type" := lToPurchHeader."Document Type"::Order;
        lToPurchHeader."No." := '1003';

        if lToPurchHeader.Insert(true) then begin
            lCopyDocMgt.SetProperties(true, false, false, false, true, false, false);
            lCopyDocMgt.CopyPurchDoc(purchDocTypes::Order, '106024', lToPurchHeader);
            lToPurchHeader.Modify(true);
        end;

        Clear(lToPurchHeader);
        lToPurchHeader."Document Type" := lToPurchHeader."Document Type"::Order;
        lToPurchHeader."No." := '1004';

        if lToPurchHeader.Insert(true) then begin
            lCopyDocMgt.SetProperties(true, false, false, false, true, false, false);
            lCopyDocMgt.CopyPurchDoc(purchDocTypes::Order, '106025', lToPurchHeader);
            lToPurchHeader.Modify(true);
        end;

        Clear(lToPurchHeader);
        lToPurchHeader."Document Type" := lToPurchHeader."Document Type"::Order;
        lToPurchHeader."No." := '1005';

        if lToPurchHeader.Insert(true) then begin
            lCopyDocMgt.SetProperties(true, false, false, false, true, false, false);
            lCopyDocMgt.CopyPurchDoc(purchDocTypes::Order, '106026', lToPurchHeader);
            lToPurchHeader.Modify(true);
        end;
    end;

    local procedure UpdatePurchLineQtyToRcpt(pPurchHeaderNo: Code[20]; pItemNo: Code[20]; pQtyToReceive: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
    begin

        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", pPurchHeaderNo);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("No.", pItemNo);
        if PurchaseLine.Find('-') then begin
            PurchaseLine.Validate("Qty. to Receive", pQtyToReceive);
            PurchaseLine.Modify(true);
        end;
    end;

    local procedure PostPartialShipmentOfPurchaseOrder1003()
    var
        PurchHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // Ein paar Bestellzeilen liefern, damit auch WE-Zeilen gezeigt werden können

        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", '1003');
        if PurchaseLine.FindSet then
            repeat
                PurchaseLine.Validate("Qty. to Receive", 0);
                PurchaseLine.Validate("Qty. to Invoice", 0);
                PurchaseLine.Modify;
            until PurchaseLine.Next = 0;
        UpdatePurchLineQtyToRcpt('1003', '70060', 100);
        UpdatePurchLineQtyToRcpt('1003', '70010', 30);
        UpdatePurchLineQtyToRcpt('1003', '70040', 40);
        UpdatePurchLineQtyToRcpt('1003', '70101', 10);


        if PurchHeader.Get(PurchHeader."Document Type"::Order, '1003') then begin
            PurchHeader.Receive := true;
            PurchHeader.Invoice := false;
            PurchHeader."Print Posted Documents" := false;
        end;

        Codeunit.Run(90, PurchHeader);
    end;

    local procedure PostShipmentOfPurchaseOrders()
    var
        PurchHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // Ein paar Bestellzeilen liefern, damit auch WE-Zeilen gezeigt werden können
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", '1004', '1005');
        if PurchaseLine.FindSet then
            repeat
                //VALIDATE("Qty. to Receive",0);
                PurchaseLine.Validate("Qty. to Invoice", 0);
                PurchaseLine.Modify;
            until PurchaseLine.Next = 0;

        if PurchHeader.Get(PurchHeader."Document Type"::Order, '1004') then begin
            PurchHeader.Receive := true;
            PurchHeader.Invoice := false;
            PurchHeader."Print Posted Documents" := false;
        end;

        Codeunit.Run(90, PurchHeader);

        if PurchHeader.Get(PurchHeader."Document Type"::Order, '1005') then begin
            PurchHeader.Receive := true;
            PurchHeader.Invoice := false;
            PurchHeader."Print Posted Documents" := false;
        end;

        Codeunit.Run(90, PurchHeader);
    end;

    local procedure DeleteSalesOrders()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("No.", '1000..1999&????');
        SalesHeader.DeleteAll(true);
    end;

    local procedure CreateItemCrossRef()
    var
        ItemCrossRef: Record "Item Cross Reference";
    begin

        ItemCrossRef.DeleteAll;

        ItemCrossRef.Init;
        ItemCrossRef.Validate("Cross-Reference Type", ItemCrossRef."Cross-Reference Type"::Customer);
        ItemCrossRef.Validate("Cross-Reference Type No.", '60000');
        ItemCrossRef.Validate("Item No.", 'LS-S15');
        ItemCrossRef.Validate("Cross-Reference No.", 'STAND-CHER');
        ItemCrossRef.Insert(true);

        ItemCrossRef.Validate("Item No.", 'LS-2');
        ItemCrossRef.Validate("Cross-Reference No.", 'LOUD-CABLES');
        ItemCrossRef.Insert(true);

        ItemCrossRef.Validate("Item No.", 'LS-150');
        ItemCrossRef.Validate("Cross-Reference No.", '150W-CHER');
        ItemCrossRef.Insert(true);
    end;

    local procedure RenameFieldNames()
    var
        TemplateField: Record "CDC Template Field";
    begin
        if TemplateField.Get('VERKAUF-DE', TemplateField.Type::Header, 'DOCNO') then begin
            TemplateField."Field Name" := 'Belegnr.';
            TemplateField.Modify(true);
        end;

        if TemplateField.Get('VERKAUF-DE', TemplateField.Type::Header, 'DOCDATE') then begin
            TemplateField."Field Name" := 'Belegdatum';
            TemplateField.Modify(true);
        end;
        //Template No.,Type,Code
    end;

    local procedure GLEntryPrepareCompany()
    var
        ReasonCode: Record "Reason Code";
        GenJournalBatch: Record "Gen. Journal Batch";
        Vendor: Record Vendor;
    begin
        // Ursachencode anlegen, damit wir ihn später weiterverwenden können
        if not ReasonCode.Get('DC') then begin
            Clear(ReasonCode);
            ReasonCode.Validate(Code, 'DC');
            ReasonCode.Validate(Description, 'Document Capture');
            ReasonCode.Insert(true);
        end;

        // Fibu Buch.-Blattnamen anlegen
        if not GenJournalBatch.Get('ALLGEMEIN', 'TANKKARTEN') then begin
            GenJournalBatch.Validate("Journal Template Name", 'ALLGEMEIN');
            GenJournalBatch.Validate(Name, 'TANKKARTEN');
            if not GenJournalBatch.Insert(true) then
                Message(StrSubstNo('%1 %2 - %2 konnte nicht angelegt werden!', GenJournalBatch.TableCaption, 'ALLGEMEIN', 'TANKKARTEN'));
        end;

        GenJournalBatch.Validate(Description, 'Tankkartenabrechnung');
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"G/L Account");
        GenJournalBatch.Validate("No. Series", 'E-RG');
        GenJournalBatch.Modify(true);

        // Kreditor anlegen/modifizieren
        if not Vendor.Get('K00010') then begin
            Vendor.Validate("No.", 'K00010');
            Vendor.Insert(true);
        end;

        Vendor.Validate(Name, 'Tankkarten Service AG');
        Vendor.Validate(Address, 'Max Müller Allee 3');
        Vendor.Validate("Address 2", 'Haus 4');
        Vendor.Validate("Post Code", '06123');
        Vendor.Validate(City, 'Halle');
        Vendor.Validate("Country/Region Code", 'DE');
        Vendor.Validate("Phone No.", '(0345) 5 55 01 90');
        Vendor.Validate("E-Mail", 'rechnungen@tankkartenservice.de');
        Vendor.Validate("VAT Registration No.", 'DE189337198');
        Vendor.Validate("Gen. Bus. Posting Group", 'INLAND');
        Vendor.Validate("VAT Bus. Posting Group", 'INLAND');
        Vendor.Validate("Vendor Posting Group", 'INLAND');
        Vendor.Validate("Language Code", 'DEU');
        Vendor.Validate("Payment Terms Code", 'LM');
        Vendor.Modify(true);
    end;

    local procedure PrepareDemo()
    var
        TemplateFieldCaption: Record "CDC Template Field Caption";
        CDCTemplateField: Record "CDC Template Field";
        CDCTemplate: Record "CDC Template";
        ItemVendor: Record "Item Vendor";
    begin

        TemplateFieldCaption.Init;
        TemplateFieldCaption."Template No." := 'EINKAUF-DE';
        TemplateFieldCaption.Type := 0;
        TemplateFieldCaption.Code := 'DOCDATE';
        TemplateFieldCaption."Line No." := 75000;
        TemplateFieldCaption.Caption := 'Rechnung vom';
        if not TemplateFieldCaption.Insert then;

        if CDCTemplateField.Get('EINKAUF-DE', CDCTemplateField.Type::Line, 'DISCAMOUNT') then begin
            CDCTemplateField."Field Name" := 'Zeilenrabatt';
            CDCTemplateField.Modify;
        end;

        if CDCTemplateField.Get('EINKAUF-DE', CDCTemplateField.Type::Line, 'DISCPCT') then begin
            CDCTemplateField."Field Name" := 'Zeilenrabatt %';
            CDCTemplateField.Modify;
        end;

        if CDCTemplate.Get('EINKAUF-DE') then begin
            CDCTemplate."Purch. Match Invoice" := CDCTemplate."Purch. Match Invoice"::"Receipt or Order";
            CDCTemplate.Modify;
        end;


        // Setup Item vendor records >>>
        CreateVendorItemRecord('61000', '1000', 'IPAD');
        CreateVendorItemRecord('61000', '1100', 'HEADSET');

        ItemVendor.SetRange(ItemVendor."Vendor No.", '30000');
        ItemVendor.DeleteAll(true);
        CreateVendorItemRecord('30000', '70060', '10-110');
        CreateVendorItemRecord('30000', '70002', '10-104');
        CreateVendorItemRecord('30000', '70010', '10-106');
        CreateVendorItemRecord('30000', '70040', '10-108');
        CreateVendorItemRecord('30000', '70101', 'P-102');
        // Setup Item vendor records <<<

        // Create legacy salespersons in BC >>>
        CreateLegacySalesperson('TZ', 'Thomas Zeilund', 'tz@contoso.com');
        CreateLegacySalesperson('AH', 'Andrea Hischer', 'ah@contoso.com');
        CreateLegacySalesperson('JR', 'Joachim Richter', 'jr@contoso.com');
        CreateLegacySalesperson('G-EINKAUF', 'Gruppe Einkauf', 'g-einkauf@contoso.com');
        CreateLegacySalesperson('G-FIBU', 'Gruppe Finanzbuchhaltung', 'g-fibu@contoso.com');
        // Create legacy salespersons in BC <<<
    end;

    local procedure CreateVendorItemRecord(VendorNo: Code[20]; ItemNo: Code[20]; VendorItemNo: Text[50]): Boolean
    var
        ItemVendor: Record "Item Vendor";
    begin
        ItemVendor.Init;
        ItemVendor."Vendor No." := VendorNo;
        ItemVendor."Item No." := ItemNo;
        ItemVendor."Vendor Item No." := VendorItemNo;
        exit(ItemVendor.Insert(true));
    end;

    local procedure CreateLegacySalesperson(SalespersonCode: Code[20]; Name: Text[50]; EMail: Text[80]): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if not Salesperson.Get(SalespersonCode) then begin
            Salesperson.init;
            Salesperson.Code := SalespersonCode;
            Salesperson.Name := Name;
            Salesperson."E-Mail" := EMail;
            exit(Salesperson.Insert(true));
        end;
    end;

    local procedure CreateDemoSetup()
    var
        DemoSetup: Record "DCADV DC Demo Setup";
        AllProfile: Record "All Profile";
    begin
        Clear(DemoSetup);
        if not DemoSetup.Get() then
            DemoSetup.Insert(true);

        DemoSetup.Validate("Template Master  Path", 'https://raw.githubusercontent.com/document-capture/demo-app/main/DemoFiles/');

        AllProfile.Init;
        AllProfile.Validate(Scope, AllProfile.Scope::System);
        AllProfile.Validate("Profile ID", 'CONTINIA-DEMO-CDC');
        AllProfile.Validate(Description, 'Continia Document Capture Demo');
        AllProfile.Validate("Role Center ID", 50000);
        AllProfile.Validate("Default Role Center", true);
        AllProfile.Insert;
    end;

    internal procedure ResetLastPostingEntries(var DemoSetup: Record "DCADV DC Demo Setup")
    begin
        DemoSetup."Purch. Rcpt. Header No." := '';
        DemoSetup."Purch. Inv. Header No." := '';
        DemoSetup."Purch. Cr. Memo Header No." := '';
        DemoSetup."G/L Entry No." := 0;
        DemoSetup."G/L VAT Entry Link No." := 0;
        DemoSetup."Cust. Ledge Entry No." := 0;
        DemoSetup."Det. Cust. Ledge Entry No." := 0;
        DemoSetup."Item Ledge. Entry No." := 0;
        DemoSetup."Vat Entry No." := 0;
        DemoSetup."Item Appl. Entry No." := 0;
        DemoSetup."Vend. Ledg. Entry No." := 0;
        DemoSetup."Det. Vend. Ledg. Entry No." := 0;
        DemoSetup."Value Entry No." := 0;
        DemoSetup."Post. Value to GL Entry No." := 0;
        DemoSetup."Purch Order No. From" := '';
        DemoSetup."Purch Order No. To" := '';
        //DemoSetup.Modify(true);
    end;

    internal procedure UpdateLastPostingEntries(var DemoSetup: Record "DCADV DC Demo Setup")
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        VendLedgEntry: Record "Vendor Ledger Entry";
        DetVendLedgeEntry: Record "Detailed Vendor Ledg. Entry";
        GLEntry: Record "G/L Entry";
        GlVatEntryLink: Record "G/L Entry - VAT Entry Link";
        CustLedgeEntry: Record "Cust. Ledger Entry";
        DetCustLedgeEntry: Record "Detailed Cust. Ledg. Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        VatEntry: Record "VAT Entry";
        ItemApplEntry: Record "Item Application Entry";
        ValueEntry: Record "Value Entry";
        PostValueEntryToGlEntry: Record "Post Value Entry to G/L";
    begin
        if PurchRcptHeader.FindLast() then
            DemoSetup."Purch. Rcpt. Header No." := PurchRcptHeader."No.";

        if PurchInvHeader.FindLast() then
            DemoSetup."Purch. Inv. Header No." := PurchInvHeader."No.";

        if PurchCrMemoHeader.FindLast() then
            DemoSetup."Purch. Cr. Memo Header No." := PurchCrMemoHeader."No.";

        if GLEntry.FindLast() then begin
            DemoSetup."G/L Entry No." := GLEntry."Entry No.";
            DemoSetup."G/L VAT Entry Link No." := GLEntry."Entry No.";
        end;

        if CustLedgeEntry.FindLast() then
            DemoSetup."Cust. Ledge Entry No." := CustLedgeEntry."Entry No.";

        if DetCustLedgeEntry.FindLast() then
            DemoSetup."Det. Cust. Ledge Entry No." := DetCustLedgeEntry."Entry No.";

        if ItemLedgerEntry.FindLast() then
            DemoSetup."Item Ledge. Entry No." := ItemLedgerEntry."Entry No.";

        if VatEntry.FindLast() then
            DemoSetup."Vat Entry No." := VatEntry."Entry No.";

        if ItemApplEntry.FindLast() then
            DemoSetup."Item Appl. Entry No." := ItemApplEntry."Entry No.";

        if VendLedgEntry.FindLast() then
            DemoSetup."Vend. Ledg. Entry No." := VendLedgEntry."Entry No.";

        if DetVendLedgeEntry.FindLast() then
            DemoSetup."Det. Vend. Ledg. Entry No." := DetVendLedgeEntry."Entry No.";

        if ValueEntry.FindLast() then
            DemoSetup."Value Entry No." := ValueEntry."Entry No.";

        if PostValueEntryToGlEntry.FindLast() then
            DemoSetup."Post. Value to GL Entry No." := PostValueEntryToGlEntry."Value Entry No.";

        DemoSetup."Purch Order No. From" := '1003';
        DemoSetup."Purch Order No. To" := '1005';

        //DemoSetup.Modify(true);

        Message('Ggf. müssen noch die Benutzer und das Genehmigungsverfahren eingerichtet werden!');
    end;



    local procedure CreateDemoDocuments()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        NoSeries: Record "No. Series";
    begin
        NoSeries.Get('E-BEST');
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, '106024') then begin
            PurchaseHeader.Init;
            PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Order);
            PurchaseHeader.Validate("No.", '106024');
            PurchaseHeader.Insert(true);
            PurchaseHeader.Validate("Buy-from Vendor No.", '30000');
            PurchaseHeader.Modify(true);

            // ,G/L Account,Item,,Fixed Asset,Charge (Item)
            CreatePurchaseLine(PurchaseHeader, 2, 10000, '70060', 250, 10.3);
            CreatePurchaseLine(PurchaseHeader, 2, 20000, '70002', 15, 22.6);
            CreatePurchaseLine(PurchaseHeader, 2, 30000, '70010', 50, 41.1);
            CreatePurchaseLine(PurchaseHeader, 2, 40000, '70040', 45, 85.4);
            CreatePurchaseLine(PurchaseHeader, 2, 50000, '70101', 85, 2.2);
            CreatePurchaseLine(PurchaseHeader, 1, 60000, '4730', 1, 462.5);
        end;

        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, '106025') then begin
            PurchaseHeader.Init;
            PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Order);
            PurchaseHeader.Validate("No.", '106025');
            PurchaseHeader.Insert(true);
            PurchaseHeader.Validate("Buy-from Vendor No.", '30000');
            PurchaseHeader.Modify(true);

            // ,G/L Account,Item,,Fixed Asset,Charge (Item)
            CreatePurchaseLine(PurchaseHeader, 2, 10000, '70060', 250, 10.3);
            CreatePurchaseLine(PurchaseHeader, 2, 20000, '70002', 15, 22.6);
            CreatePurchaseLine(PurchaseHeader, 2, 30000, '70010', 50, 41.1);
        end;

        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, '106026') then begin
            PurchaseHeader.Init;
            PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Order);
            PurchaseHeader.Validate("No.", '106026');
            PurchaseHeader.Insert(true);
            PurchaseHeader.Validate("Buy-from Vendor No.", '30000');
            PurchaseHeader.Modify(true);

            // ,G/L Account,Item,,Fixed Asset,Charge (Item)
            CreatePurchaseLine(PurchaseHeader, 2, 10000, '70040', 45, 85.4);
            CreatePurchaseLine(PurchaseHeader, 2, 20000, '70101', 85, 2.2);
        end;

        NoSeries.Validate("Manual Nos.", false);
        NoSeries.Modify(true);
    end;

    local procedure CreatePurchaseLine(var PurchaseHeader: Record "Purchase Header"; LineType: Integer; LineNo: Integer; No: Code[20]; Qty: Decimal; PurchPrice: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");

        PurchaseLine.Validate("Line No.", LineNo);
        PurchaseLine.Insert(true);
        PurchaseLine.Validate(Type, LineType);
        PurchaseLine.Validate("No.", No);
        PurchaseLine.Validate(Quantity, Qty);
        PurchaseLine.Validate("Direct Unit Cost", PurchPrice);
        PurchaseLine.Modify(true);
    end;

    local procedure DeleteAbsenceSharedApprovals()
    var
        SharedApprovals: Record "CDC Approval Sharing";
    begin
        SharedApprovals.SetRange("Sharing Type", SharedApprovals."Sharing Type"::"Out of Office");
        SharedApprovals.DeleteAll();
    end;
}

