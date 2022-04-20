page 63010 "DCADV DC Demo Setup Card"
{

    Caption = 'DC Demo Setup Card';
    PageType = Card;
    SourceTable = "DCADV DC Demo Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Template Language"; Rec."Template Language")
                {
                    ToolTip = 'Specifies the value of the Template Language field';
                    ApplicationArea = All;
                    trigger

                    OnLookup(var Text: Text): Boolean
                    begin
                        DemoSetupMgt.SelectDemoTemplateLanguage();
                        CurrPage.Update(false);
                    end;
                }
                field("Template Master  Path"; Rec."Template Master  Path")
                {
                    ToolTip = 'Specifies the value of the Template Master  Path field';
                    ApplicationArea = All;

                }
            }
            part("Documents"; "DCADV DC Demo Document List")
            {
                ApplicationArea = All;
            }

            group("Reset Options")
            {
                field("Reset Posting Entries"; Rec."Reset Posting Entries")
                {
                    ToolTip = 'Specifies if the demo reset will reset all system entries to its initial values';
                    ApplicationArea = All;
                }
                field("Delete absence sh. approvals"; Rec."Delete absence sh. approvals")
                {
                    ToolTip = 'Specifies if the demo reset will remove all shared approval entries of type absence, that might have been created during a demo';
                    ApplicationArea = All;
                }
            }
            group("Posting Documentation")
            {
                field("Cust. Ledge Entry No."; Rec."Cust. Ledge Entry No.")
                {
                    ToolTip = 'Specifies the value of the Cust. Ledge Entry No. field';
                    ApplicationArea = All;
                }
                field("Det. Cust. Ledge Entry No."; Rec."Det. Cust. Ledge Entry No.")
                {
                    ToolTip = 'Specifies the value of the Det. Cust. Ledge Entry No. field';
                    ApplicationArea = All;
                }
                field("Det. Vend. Ledg. Entry No."; Rec."Det. Vend. Ledg. Entry No.")
                {
                    ToolTip = 'Specifies the value of the Det. Vend. Ledg. Entry No. field';
                    ApplicationArea = All;
                }
                field("G/L Entry No."; Rec."G/L Entry No.")
                {
                    ToolTip = 'Specifies the value of the G/L Entry No. field';
                    ApplicationArea = All;
                }
                field("G/L VAT Entry Link No."; Rec."G/L VAT Entry Link No.")
                {
                    ToolTip = 'Specifies the value of the G/L VAT Entry Link No. field';
                    ApplicationArea = All;
                }
                field("Item Appl. Entry No."; Rec."Item Appl. Entry No.")
                {
                    ToolTip = 'Specifies the value of the Item Appl. Entry No. field';
                    ApplicationArea = All;
                }
                field("Item Ledge. Entry No."; Rec."Item Ledge. Entry No.")
                {
                    ToolTip = 'Specifies the value of the Item Ledge. Entry No. field';
                    ApplicationArea = All;
                }
                field("Post. Value to GL Entry No."; Rec."Post. Value to GL Entry No.")
                {
                    ToolTip = 'Specifies the value of the Post. Value to GL Entry No. field';
                    ApplicationArea = All;
                }
                field("Purch Order No. From"; Rec."Purch Order No. From")
                {
                    ToolTip = 'Specifies the value of the Purch Order No. From field';
                    ApplicationArea = All;
                }
                field("Purch Order No. To"; Rec."Purch Order No. To")
                {
                    ToolTip = 'Specifies the value of the Purch Order No. To field';
                    ApplicationArea = All;
                }
                field("Purch. Cr. Memo Header No."; Rec."Purch. Cr. Memo Header No.")
                {
                    ToolTip = 'Specifies the value of the Purch. Cr. Memo Header No. field';
                    ApplicationArea = All;
                }
                field("Purch. Inv. Header No."; Rec."Purch. Inv. Header No.")
                {
                    ToolTip = 'Specifies the value of the Purch. Inv. Header No. field';
                    ApplicationArea = All;
                }
                field("Purch. Rcpt. Header No."; Rec."Purch. Rcpt. Header No.")
                {
                    ToolTip = 'Specifies the value of the Purch. Rcpt. Header No. field';
                    ApplicationArea = All;
                }
                field("Value Entry No."; Rec."Value Entry No.")
                {
                    ToolTip = 'Specifies the value of the Value Entry No. field';
                    ApplicationArea = All;
                }
                field("Vat Entry No."; Rec."Vat Entry No.")
                {
                    ToolTip = 'Specifies the value of the Vat Entry No. field';
                    ApplicationArea = All;
                }
                field("Vend. Ledg. Entry No."; Rec."Vend. Ledg. Entry No.")
                {
                    ToolTip = 'Specifies the value of the Vend. Ledg. Entry No. field';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Download Demo Documents")
            {
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Refresh;

                trigger OnAction()
                var
                    DemoMgt: Codeunit "DCADV DC Demo Setup";
                begin
                    DemoMgt.DownloadDemoDocuments();
                    CurrPage.Update(false);
                end;
            }
            action("Create User")
            {
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Refresh;

                trigger OnAction()
                var
                    DemoMgt: Codeunit "DCADV DC Demo Setup";
                begin
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action("Document Capture Setup")
            {
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Setup;
                RunObject = page "CDC Document Capture Setup";
                RunPageMode = Edit;
            }
            action("Continia User Setup")
            {
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = UserSetup;
                RunObject = page "CDC Continia User Setup List";
                RunPageMode = Edit;
            }
            action("Salesperson/Purchaser")
            {
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = SalesPerson;
                RunObject = page "Salespersons/Purchasers";
                RunPageMode = Edit;
            }
        }
    }

    var
        DemoSetupMgt: Codeunit "DCADV DC Demo Setup";
}
