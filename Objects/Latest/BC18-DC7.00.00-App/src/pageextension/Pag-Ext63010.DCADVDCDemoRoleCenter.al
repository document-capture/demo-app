pageextension 63010 "DCADV DC Demo Role Center" extends "CDC Doc. Capture Role Center"
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
                RunObject = Codeunit "DCADV DC Demo Setup";
                ApplicationArea = All;
            }
        }
    }
}