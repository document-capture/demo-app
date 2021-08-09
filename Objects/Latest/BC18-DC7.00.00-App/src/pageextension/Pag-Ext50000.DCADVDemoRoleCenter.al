pageextension 50000 "DCADV Demo Role Center" extends "CDC Doc. Capture Role Center"
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
                RunObject = Codeunit "DCADV Reset DC Demo Setup";
            }
        }
    }
}