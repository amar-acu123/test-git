trigger accounttriggername on Account (before update) {
    for(account a : trigger.new){
        a.industry = 'asdf';
    }
}