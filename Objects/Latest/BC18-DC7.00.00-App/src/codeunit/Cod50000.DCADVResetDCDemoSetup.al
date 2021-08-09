codeunit 50000 "DCADV Reset DC Demo Setup"
{
    // Codeunit, welches die CDC Demoumgebung zurücksetzen kann
    trigger OnRun()
    var
        DemoSetup: Record "DCADV DC Demo Setup";
    begin
        if not Confirm(Text001, false) then
            Error('Zurücksetzen wurde abgebrochen, es wurden keine Daten geändert!');

        if not DemoSetup.Get then begin
            CreateDemoSetup;
            CreateDemoDocuments;
        end;

        //Ungebuchte Belege löschen
        DeleteDocuments();

        // Posten löschen/aufräumen
        DeleteEntries();

        CopyDemoFilesToImportFolder();

        DeleteRecordIDTree();
        DeleteTemplates();
        DeleteApprovalEntries();
        ResetVendors();
        CreatePurchaseOrders();
        PostShipmentOfPurchaseOrders;
        //PostPartialShipmentOfPurchaseOrder1003;

        //Prepare Demo
        PrepareDemo;

        // Verkauf
        DeleteSalesOrders();
        CreateItemCrossRef();
        RenameFieldNames();

        // GL/Entry
        //GLEntryPrepareCompany;

        // Exprt document categories
        REPORT.Run(REPORT::"CDC Export OCR Config. Files", false, false);

        // Document Output
        //CODEUNIT.RUN(50001);
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

    local procedure DeleteDCOrders()
    begin
    end;

    local procedure CopyDemoFilesToImportFolder()
    var
        lDCSetup: Record "CDC Document Capture Setup";
        lDCCategory: Record "CDC Document Category";
        lContiniaCompanySetup: Record "CDC Continia Company Setup";
        lDirInfo: DotNet DirectoryInfo;
        lCurrDirInfo: DotNet DirectoryInfo;
        lFile: DotNet File;
        lFolder: DotNet Directory;
        lPath: DotNet Path;
        lGenList: DotNet List_Of_T;
        lObj: DotNet Object;
        lCurrPath: Text;
        lCatPath: Text[1024];
        i: Integer;
        j: Integer;
    begin
        with lDCSetup do begin
            Get;
            TestField("File Path for OCR-proc. files");
            TestField("XML File Path");

            lContiniaCompanySetup.Get;
            lCurrPath := lPath.Combine(lDCSetup."Archive File Path", lContiniaCompanySetup."Company Code");

            // Archiv bereinigen >>>
            if lFolder.Exists(lCurrPath) then begin
                lDirInfo := lDirInfo.DirectoryInfo(lCurrPath);
                lObj := lDirInfo.GetDirectories();
                lGenList := lGenList.List;
                lGenList.AddRange(lObj);
                for i := 0 to lGenList.Count - 1 do begin
                    lFolder.Delete(lPath.Combine(lCurrPath, Format(lGenList.Item(i))), true);
                end;
            end;
            // Archiv bereinigen <<<

            // Iteriere durch alle Belegkategorien
            if lDCCategory.FindSet then
                repeat

                    // Vorhandene Ordner und Dateien entfernen
                    for j := 1 to 4 do begin
                        if lFolder.Exists(lDCCategory.GetCategoryPath(j)) then begin
                            lDirInfo := lDirInfo.DirectoryInfo(lDCCategory.GetCategoryPath(j));
                            lObj := lDirInfo.GetDirectories();
                            lGenList := lGenList.List;
                            lGenList.AddRange(lObj);
                            for i := 0 to lGenList.Count - 1 do begin
                                lCurrDirInfo := lCurrDirInfo.DirectoryInfo(Format(lGenList.Item(i)));
                                if lFolder.Exists(Format(lGenList.Item(i))) then
                                    if UpperCase(lCurrDirInfo.Name) <> 'BACKUP' then
                                        lFolder.Delete(Format(lGenList.Item(i)), true);
                            end;

                            lObj := lFolder.GetFiles(lDCCategory.GetCategoryPath(j));
                            lGenList := lGenList.List;
                            lGenList.AddRange(lObj);
                            for i := 0 to lGenList.Count - 1 do begin
                                lFile.Delete(Format(lGenList.Item(i)));
                            end;

                            // Copy backup files to current directory
                            if lFolder.Exists(lPath.Combine(lDCCategory.GetCategoryPath(j), 'BACKUP')) then begin
                                lObj := lFolder.GetFiles(lPath.Combine(lDCCategory.GetCategoryPath(j), 'BACKUP'));
                                lGenList := lGenList.List;
                                lGenList.AddRange(lObj);
                                // Iteration durch die gefundenen Dateien
                                for i := 0 to lGenList.Count - 1 do begin
                                    lFile.Copy(Format(lGenList.Item(i)),
                                           lPath.Combine(lDCCategory.GetCategoryPath(j), lPath.GetFileName(Format(lGenList.Item(i)))));
                                end;
                            end;
                        end;
                    end;
                until lDCCategory.Next = 0;
        end;
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
        lPurchLine: Record "Purchase Line";
    begin
        with lPurchLine do begin
            SetRange("Document Type", lPurchLine."Document Type"::Order);
            SetRange("Document No.", pPurchHeaderNo);
            SetRange(Type, lPurchLine.Type::Item);
            SetRange("No.", pItemNo);
            if Find('-') then begin
                Validate("Qty. to Receive", pQtyToReceive);
                Modify(true);
            end;
        end;


    end;

    local procedure PostPartialShipmentOfPurchaseOrder1003()
    var
        lPurchHeader: Record "Purchase Header";
        lPurchLine: Record "Purchase Line";
    begin
        // Ein paar Bestellzeilen liefern, damit auch WE-Zeilen gezeigt werden können
        with lPurchLine do begin
            SetRange("Document Type", lPurchLine."Document Type"::Order);
            SetRange("Document No.", '1003');
            if FindSet then
                repeat
                    Validate("Qty. to Receive", 0);
                    Validate("Qty. to Invoice", 0);
                    Modify;
                until Next = 0;
            UpdatePurchLineQtyToRcpt('1003', '70060', 100);
            UpdatePurchLineQtyToRcpt('1003', '70010', 30);
            UpdatePurchLineQtyToRcpt('1003', '70040', 40);
            UpdatePurchLineQtyToRcpt('1003', '70101', 10);
        end;

        if lPurchHeader.Get(lPurchHeader."Document Type"::Order, '1003') then begin
            lPurchHeader.Receive := true;
            lPurchHeader.Invoice := false;
            lPurchHeader."Print Posted Documents" := false;
        end;

        CODEUNIT.Run(90, lPurchHeader);
    end;

    local procedure PostShipmentOfPurchaseOrders()
    var
        lPurchHeader: Record "Purchase Header";
        lPurchLine: Record "Purchase Line";
    begin
        // Ein paar Bestellzeilen liefern, damit auch WE-Zeilen gezeigt werden können
        with lPurchLine do begin
            SetRange("Document Type", lPurchLine."Document Type"::Order);
            SetRange("Document No.", '1004', '1005');
            if FindSet then
                repeat
                    //VALIDATE("Qty. to Receive",0);
                    Validate("Qty. to Invoice", 0);
                    Modify;
                until Next = 0;
        end;

        if lPurchHeader.Get(lPurchHeader."Document Type"::Order, '1004') then begin
            lPurchHeader.Receive := true;
            lPurchHeader.Invoice := false;
            lPurchHeader."Print Posted Documents" := false;
        end;

        CODEUNIT.Run(90, lPurchHeader);

        if lPurchHeader.Get(lPurchHeader."Document Type"::Order, '1005') then begin
            lPurchHeader.Receive := true;
            lPurchHeader.Invoice := false;
            lPurchHeader."Print Posted Documents" := false;
        end;

        CODEUNIT.Run(90, lPurchHeader);
    end;

    local procedure DeleteSalesOrders()
    var
        lSalesHeader: Record "Sales Header";
    begin
        lSalesHeader.SetRange("Document Type", lSalesHeader."Document Type"::Order);
        lSalesHeader.SetFilter("No.", '1000..1999&????');
        lSalesHeader.DeleteAll(true);
    end;

    local procedure CreateItemCrossRef()
    var
        lItemCrossRef: Record "Item Cross Reference";
    begin
        with lItemCrossRef do begin
            DeleteAll;

            Init;
            Validate("Cross-Reference Type", "Cross-Reference Type"::Customer);
            Validate("Cross-Reference Type No.", '60000');
            Validate("Item No.", 'LS-S15');
            Validate("Cross-Reference No.", 'STAND-CHER');
            Insert(true);

            Validate("Item No.", 'LS-2');
            Validate("Cross-Reference No.", 'LOUD-CABLES');
            Insert(true);

            Validate("Item No.", 'LS-150');
            Validate("Cross-Reference No.", '150W-CHER');
            Insert(true);
        end;
    end;

    local procedure RenameFieldNames()
    var
        lTemplateField: Record "CDC Template Field";
    begin
        if lTemplateField.Get('VERKAUF-DE', lTemplateField.Type::Header, 'DOCNO') then begin
            lTemplateField."Field Name" := 'Belegnr.';
            lTemplateField.Modify(true);
        end;

        if lTemplateField.Get('VERKAUF-DE', lTemplateField.Type::Header, 'DOCDATE') then begin
            lTemplateField."Field Name" := 'Belegdatum';
            lTemplateField.Modify(true);
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
        with TemplateFieldCaption do begin
            Init;
            "Template No." := 'EINKAUF-DE';
            Type := 0;
            Code := 'DOCDATE';
            "Line No." := 75000;
            Caption := 'Rechnung vom';
            if not Insert then;
        end;

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
        AllProfile: Record "All Profile";
    begin
        Clear(DemoSetup);
        DemoSetup.Insert(true);

        DemoSetup."Template Master  Path" := 'https://raw.githubusercontent.com/document-capture/demo-app/main/DemoFiles/master.config.xml';

        if PurchRcptHeader.FindLast then
            DemoSetup."Purch. Rcpt. Header No." := PurchRcptHeader."No.";

        if PurchInvHeader.FindLast then
            DemoSetup."Purch. Inv. Header No." := PurchInvHeader."No.";

        if PurchCrMemoHeader.FindLast then
            DemoSetup."Purch. Cr. Memo Header No." := PurchCrMemoHeader."No.";

        if GLEntry.FindLast then begin
            DemoSetup."G/L Entry No." := GLEntry."Entry No.";
            DemoSetup."G/L VAT Entry Link No." := GLEntry."Entry No.";
        end;

        if CustLedgeEntry.FindLast then
            DemoSetup."Cust. Ledge Entry No." := CustLedgeEntry."Entry No.";

        if DetCustLedgeEntry.FindLast then
            DemoSetup."Det. Cust. Ledge Entry No." := DetCustLedgeEntry."Entry No.";

        if ItemLedgerEntry.FindLast then
            DemoSetup."Item Ledge. Entry No." := ItemLedgerEntry."Entry No.";

        if VatEntry.FindLast then
            DemoSetup."Vat Entry No." := VatEntry."Entry No.";

        if ItemApplEntry.FindLast then
            DemoSetup."Item Appl. Entry No." := ItemApplEntry."Entry No.";

        if VendLedgEntry.FindLast then
            DemoSetup."Vend. Ledg. Entry No." := VendLedgEntry."Entry No.";

        if DetVendLedgeEntry.FindLast then
            DemoSetup."Det. Vend. Ledg. Entry No." := DetVendLedgeEntry."Entry No.";

        if ValueEntry.FindLast then
            DemoSetup."Value Entry No." := ValueEntry."Entry No.";

        if PostValueEntryToGlEntry.FindLast then
            DemoSetup."Post. Value to GL Entry No." := PostValueEntryToGlEntry."Value Entry No.";

        DemoSetup."Purch Order No. From" := '1003';
        DemoSetup."Purch Order No. To" := '1005';

        DemoSetup.Modify(true);

        AllProfile.Init;
        AllProfile.Validate(Scope, AllProfile.Scope::System);
        AllProfile.Validate("Profile ID", 'CONTINIA-DEMO-CDC');
        AllProfile.Validate(Description, 'Continia Document Capture Demo');
        AllProfile.Validate("Role Center ID", 50000);
        AllProfile.Validate("Default Role Center", true);
        AllProfile.Insert;

        Message('Ggf. müssen noch die Benutzer und das Genehmigungsverfahren eingerichtet werden!');
    end;

    procedure SelectDemoTemplateLanguage()
    var
        DemoSetup: Record "DCADV DC Demo Setup";
        LanguageBuffer: Record Language temporary;
        Http: Codeunit "CSC Http";

        XmlDoc: Codeunit "CSC XML Document";
        DocumentElement: Codeunit "CSC XML Node";
        XmlNodes: Codeunit "CSC XML NodeList";
        LanguageNode: Codeunit "CSC XML Node";
        i: Integer;
    begin
        DemoSetup.Get();
        DemoSetup.TestField("Template Master  Path");
        if Http.ExecuteXmlDocRequest(DemoSetup."Template Master  Path", 2, true, XmlDoc) then begin
            XmlDoc.GetDocumentElement(DocumentElement);
            DocumentElement.SelectNodes(XmlNodes, 'Language');

            for i := 0 to XmlNodes.Count() - 1 do begin
                XmlNodes.GetItem(LanguageNode, i)
            end;
        end;
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
}

