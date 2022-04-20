codeunit 63011 "DCADV DC Setup Mgt. Install"
{
    Subtype = Install;

    var
        DemoSetup: Record "DCADV DC Demo Setup";

    trigger OnInstallAppPerCompany();
    begin
        if not DemoSetup.Get() then
            DemoSetup.Insert(true);

        if DemoSetup."Template Master  Path" = '' then
            DemoSetup.Validate("Template Master  Path", 'https://raw.githubusercontent.com/document-capture/demo-app/main/DemoFiles/');

        DemoSetup.Modify(true);
    end;

    trigger OnInstallAppPerDatabase();
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        myAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(myAppInfo);

        if myAppInfo.DataVersion = Version.Create(0, 0, 0, 0) then
            HandleFreshInstall
        else
            HandleReinstall;

        UpgradeTag.SetAllUpgradeTags();
    end;

    local procedure HandleFreshInstall();
    begin

    end;

    local procedure HandleReinstall();
    begin

    end;
}