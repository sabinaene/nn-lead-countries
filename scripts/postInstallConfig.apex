CountryLayerScheduler countryUpdate = new CountryLayerScheduler();
String jobTime = '0 0 0 * * ?';
String jobId = System.schedule('Daily CountryLayer.com API Check', jobTime, countryUpdate);