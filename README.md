# NN Lead Countries

Unlocked package with the Salesforce coding exercise April 2024, including:
* Nightly job to refresh country data in the org from CountryLayer.com free API
* Automatic update of country data on Lead records whenever the country data is refreshed from API or the Lead country changes
* Validation and tracking changes for Lead Owner updates

## Installation with Salesforce CLI
You need to install [Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm).

First, you need to authorise the org where you want to install the package.
```bash
sf org login web --alias TestOrg --instance-url https://login.salesforce.com
```
The login page should open in the browser for you to authorise the org.

Next, install package version 1.0.
```bash
sf package install --package 04t06000000kodRAAQ --wait 10 --target-org TestOrg
```
You will be asked to confirm third party access for api.countrylayer.com. To bypass that, add `--no-prompt` to the command above.

Then add your API access key to custom settings. You can create your API key [here](https://manage.countrylayer.com/signup/free).
```bash
sf data create record --sobject CountryLayerAPI__c  --values "Name='<SettingName>' SetupOwnerId='<User/Profile/Org ID>' AccessKey__c='<access key>'" --target-org TestOrg
```

Next, assign the `ReadCountries` permission set to all the users who should be able to update country data on Leads.
```bash
sf org assign permset --name ReadCountries --target-org TestOrg --on-behalf-of <user1> --on-behalf-of <user2> --on-behalf-of <userN>
```

Finish configuration by running the anonymous code in `scripts/postInstallConfig.apex` that schedules the nightly country data refreshes from CountryLayer.com API.
```bash
sf apex run --file scripts/postInstallConfig.apex --target-org TestOrg
```

## Manual Installation
1. First, install package version 1.0 in your org from [here](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t06000000kodRAAQ).

2. Then add your API access key to custom settings. Navigate to **Setup** > **Custom Settings**, select **CountryLayerAPI__c**, click **Manage**, and add a new entry for the selected User/Profile/Org ID and with your API key. You can create your API key [here](https://manage.countrylayer.com/signup/free).

3. Next, assign the `Read Countries` permission set to all the users who should be able to update country data on Leads. Navigate to **Setup** > **Permission Sets**, select **Read Countries**, click **Manage Assignments**, and add all the needed users.

4. Finish configuration by scheduling the nightly country data refreshes from CountryLayer.com API. You can run the 
the anonymous code in `scripts/postInstallConfig.apex` from the **Developer Console**; or simply go to **Setup** > **Apex Classes**, click **Schedule Apex**, and create a new job for the `CountryLayerScheduler` class.