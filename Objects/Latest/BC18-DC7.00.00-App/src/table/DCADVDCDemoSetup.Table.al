table 63010 "DCADV DC Demo Setup"
{

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = ToBeClassified;
        }

        field(3; "Template Master  Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }

        field(4; "Template Language"; Text[7])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Purch. Rcpt. Header No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Purch. Rcpt. Header";
        }
        field(11; "Purch. Inv. Header No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Purch. Inv. Header";
        }
        field(12; "Purch. Cr. Memo Header No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Purch. Cr. Memo Hdr.";
        }
        field(15; "G/L Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Entry"."Entry No.";
        }
        field(16; "G/L VAT Entry Link No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Entry - VAT Entry Link";
        }
        field(17; "Cust. Ledge Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Cust. Ledger Entry";
        }
        field(18; "Det. Cust. Ledge Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Detailed Cust. Ledg. Entry";
        }
        field(19; "Item Ledge. Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Ledger Entry";
        }
        field(20; "Vat Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "VAT Entry";
        }
        field(21; "Item Appl. Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Application Entry";
        }
        field(22; "Vend. Ledg. Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Vendor Ledger Entry";
        }
        field(23; "Det. Vend. Ledg. Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Detailed Vendor Ledg. Entry";
        }
        field(24; "Value Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Value Entry";
        }
        field(25; "Post. Value to GL Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Post Value Entry to G/L";
        }
        field(30; "Purch Order No. From"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Invoice));
        }
        field(31; "Purch Order No. To"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Invoice));
        }
        field(50; "Reset Posting Entries"; Boolean)
        {
            Caption = 'Reset posting entries';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                DemoMgt: Codeunit "DCADV DC Demo Setup";
            begin
                if ("Reset Posting Entries" = true) and (xRec."Reset Posting Entries" = false) then
                    DemoMgt.UpdateLastPostingEntries(Rec);

                if (Rec."Reset Posting Entries" = false) and (xRec."Reset Posting Entries" = true) then
                    if Confirm('Do you want to reset the stored posting entries values?', false) then
                        DemoMgt.ResetLastPostingEntries(Rec);
            end;
        }
        field(51; "Delete absence sh. approvals"; Boolean)
        {
            Caption = 'Delete sh. approvals for absence';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

