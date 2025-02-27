import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'login.dart'; // 로그인 화면 import
import 'checklist.dart';
import 'nutrition.dart';
import 'static.dart';
import 'goal.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(), // 처음 화면을 로그인 화면으로 설정
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedPageIndex = 0;

  Map<DateTime, Map<String, dynamic>> _dateData = {
    DateTime.utc(2024, 10, 1): {
      'checklist': ['운동하기', '영양제 복용'],
      'nutrition': {'칼로리': 2200, '단백질': 150},
      'goal': '5km 달리기',
    },
    DateTime.utc(2024, 10, 2): {
      'checklist': ['스트레칭', '물 2L 마시기'],
      'nutrition': {'칼로리': 1800, '단백질': 130},
      'goal': '책 30페이지 읽기',
    },
  };

  Map<String, dynamic> _currentData = {};
  //추가
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadDataForSelectedDay(_focusedDay);
  }

  void _loadDataForSelectedDay(DateTime selectedDay) {
    setState(() {
      _currentData = _dateData[selectedDay] ?? {
        'checklist': ['데이터 없음'],
        'nutrition': {'칼로리': 0, '단백질': 0},
        'goal': '목표 없음',
      };
      //추가
      // 텍스트 필드에 데이터 반영
      _calorieController.text = _currentData['nutrition']['칼로리'].toString();
      _proteinController.text = _currentData['nutrition']['단백질'].toString();
    });
  }


  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _loadDataForSelectedDay(selectedDay);
              });
              Navigator.pop(context); // 팝업 닫기
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
          ),
        );
      },
    );
  }

  void _nextWeek() {
    setState(() {
      _focusedDay = _focusedDay.add(Duration(days: 7));
    });
  }

  void _previousWeek() {
    setState(() {
      _focusedDay = _focusedDay.subtract(Duration(days: 7));
    });
  }
  //추가
  void _updateNutrition() {
    setState(() {
      _currentData['nutrition']['칼로리'] = int.tryParse(_calorieController.text) ?? 0;
      _currentData['nutrition']['단백질'] = int.tryParse(_proteinController.text) ?? 0;

      // 선택된 날짜의 데이터를 업데이트합니다.
      _dateData[_selectedDay ?? _focusedDay] = _currentData;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Life Style'),
        backgroundColor: Color(0xffB81736),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _showCalendarDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWeekDates(),
          Expanded(
            child: IndexedStack(
              index: _selectedPageIndex,
              children: [
                _buildChecklistPage(),
                _buildNutritionPage(),
                StaticPage(),
                _buildGoalPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: '체크리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.link),
            label: '영양제',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: '목표',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildWeekDates() {
    DateTime startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _previousWeek,
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                DateTime date = startOfWeek.add(Duration(days: index));
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = date;
                      _loadDataForSelectedDay(date);
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 8.5,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: date == _selectedDay ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${date.month}/${date.day}", // 월/날짜 형식으로 표시
                          style: TextStyle(
                            color: date == _selectedDay ? Colors.blue : Colors.black,
                            fontWeight: date == _selectedDay ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "${["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1]}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: _nextWeek,
        ),
      ],
    );
  }

  Widget _buildChecklistPage() {
    List<String> checklist = _currentData['checklist'] ?? ['데이터 없음'];
    return ListView.builder(
      itemCount: checklist.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(checklist[index]),
        );
      },
    );
  }
//수정
  Widget _buildNutritionPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _calorieController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '칼로리 (kcal)'),
          ),
          TextField(
            controller: _proteinController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '단백질 (g)'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateNutrition,
            child: Text('저장하기'),
          ),
        ],
      ),
    );
  }


  Widget _buildGoalPage() {
    String goal = _currentData['goal'] ?? '목표 없음';
    return Center(
      child: Text('오늘의 목표: $goal'),
    );
  }
}
