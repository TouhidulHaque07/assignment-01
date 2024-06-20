
class car{
  String brand='';
  String model='';
  int year = 0;
  double milesDriven=0.0;

  static int numberOfCars=0;

  car(String brand, String model, int year){

    this.brand=brand;
    this.model=model;
    this.year=year;

    numberOfCars++;
  }

  drive(double miles){
    this.milesDriven=miles;
  }

  double getMilesDriven(){
    return milesDriven;
  }

  String getBrand(){
    return brand;
  }

  String getModel(){
    return model;
 }

  int getYear(){
    return year;
  }

  String getAge(){

    DateTime nowdate=DateTime.now();
    int currentYear=nowdate.year;
    int age=currentYear-this.year;

    return age.toString();
  }

}

void main(){

  car TOYOTA=car('TOYOTA', 'T-100', 1990);
  TOYOTA.drive(1200.00);
  print('Car Brand Name :' + TOYOTA.getBrand()+'\n'
        'Car Model Name : '+ TOYOTA.getModel()+'\n'
        'Car Year       :'+  TOYOTA.getYear().toString() +'\n'
        'Car Miles Driven:'+TOYOTA.getMilesDriven().toString()+'\n'
          'Car Age       :'+TOYOTA.getAge());

  print('---------------------------------------------------\n');

  car BMW=car('BMW', 'BMW-101', 1995);
  BMW.drive(1500.00);
  print('Car Brand Name :' + BMW.getBrand()+'\n'
      'Car Model Name : '+ BMW.getModel()+'\n'
      'Car Year       :'+  BMW.getYear().toString() +'\n'
      'Car Miles Driven:'+BMW.getMilesDriven().toString()+'\n'
      'Car Age       :'+BMW.getAge());

  print('---------------------------------------------------\n');

  car ford=car('Ford', 'F-5001', 2001);
  ford.drive(1800.00);

  print('Car Brand Name :' + ford.getBrand()+'\n'
      'Car Model Name : '+ ford.getModel()+'\n'
      'Car Year       :'+  ford.getYear().toString() +'\n'
      'Car Miles Driven:'+ ford.getMilesDriven().toString()+'\n'
      'Car Age       :'+ ford.getAge());

  print('\n ** Number of Car Created:'+car.numberOfCars.toString());

}