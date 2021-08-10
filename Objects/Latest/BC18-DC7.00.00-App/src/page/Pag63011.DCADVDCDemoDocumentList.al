page 63011 "DCADV DC Demo Document List"
{

    Caption = 'Document List';
    PageType = ListPart;
    SourceTable = "DCADV DC Demo Document";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                }
                field("File Type"; "File Type")
                {
                    ToolTip = 'Specifies the file type of the demo document';
                    ApplicationArea = All;
                }
                field("Document Category"; Rec."Document Category")
                {
                    ToolTip = 'Specifies the value of the Document Category field';
                    ApplicationArea = All;
                }
                field("Pdf Content"; Rec."Pdf Content".HasValue)
                {
                    ToolTip = 'Specifies the value of the Pdf Content field';
                    ApplicationArea = All;
                }
                field("Png Content"; Rec."Png Content".HasValue)
                {
                    ToolTip = 'Specifies the value of the Png Content field';
                    ApplicationArea = All;
                }
                field("Tiff Content"; Rec."Tiff Content".HasValue)
                {
                    ToolTip = 'Specifies the value of the Tiff Content field';
                    ApplicationArea = All;
                }
                field("OCR Content"; Rec."OCR Content".HasValue)
                {
                    ToolTip = 'Specifies the value of the OCR content field';
                    ApplicationArea = All;
                }
                field("XML Content"; Rec."XML Content".HasValue)
                {
                    ToolTip = 'Specifies the value of the XML content field';
                    ApplicationArea = All;
                }
            }
        }
    }

}
