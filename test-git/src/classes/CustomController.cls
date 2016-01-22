public class CustomController {
       public CustomController() {
           clickCount = 0;
       }
       public Integer clickCount {get;set;}
       public void buttonClicked() {
           clickCount++;
       }
}