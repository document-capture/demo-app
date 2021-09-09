table 63011 "DCADV DC Demo Document"
{
    Caption = 'DCADV Demo Document';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "File Type"; Enum "DCADV File Type")
        {
            Caption = 'File Type';
            DataClassification = CustomerContent;
        }
        field(6; "Document Category"; Code[10])
        {
            Caption = 'Document Category';
            DataClassification = CustomerContent;
            TableRelation = "CDC Document Category".Code;
            ValidateTableRelation = true;
        }
        field(10; "Pdf Content"; Blob)
        {
            Caption = 'Pdf Content';
            DataClassification = CustomerContent;
        }
        field(11; "Tiff Content"; Blob)
        {
            Caption = 'Tiff Content';
            DataClassification = CustomerContent;
        }
        field(12; "Png Content"; Blob)
        {
            Caption = 'Png Content';
            DataClassification = CustomerContent;
        }
        field(13; "OCR Content"; Blob)
        {
            Caption = 'OCR Content';
            DataClassification = CustomerContent;
        }
        field(14; "XML Content"; Blob)
        {
            Caption = 'XML Content';
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }
    }

}
