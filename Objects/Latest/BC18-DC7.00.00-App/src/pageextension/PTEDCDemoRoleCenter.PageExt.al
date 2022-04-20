pageextension 63010 "PTE DC Demo Role Center" extends "CDC Doc. Capture Role Center"
{
    actions
    {
        addafter("Data Deletion")
        {
            action("Zurücksetzen")
            {
                Caption = 'Zurücksetzen';
                Image = ResetStatus;
                Promoted = true;
                RunObject = Codeunit "PTE DC Demo Setup";
                ApplicationArea = All;
            }
        }
    }
}