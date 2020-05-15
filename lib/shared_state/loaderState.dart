import 'change_notifier.dart';

enum States {
  LOADING,
  IDLE,
  COMPLETED
}
class LoaderState extends SentinelXChangeNotifier{
  String loadingXpub = "all";
  States state = States.IDLE;

  setLoadingXpub(String xpub){
    this.loadingXpub = xpub;
    this.notifyListeners();
  }

  setLoadingState(States state){
    this.state = state;
    this.notifyListeners();
  }

  setLoadingStateAndXpub(States state,String xpub){
    this.state = state;
    this.loadingXpub = xpub;
    this.notifyListeners();
  }

}