// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:sky/painting/text_style.dart';
import 'package:sky/widgets/basic.dart';
import 'package:sky/widgets/card.dart';
import 'package:sky/widgets/default_text_style.dart';
import 'package:sky/widgets/dismissable.dart';
import 'package:sky/widgets/drawer.dart';
import 'package:sky/widgets/drawer_divider.dart';
import 'package:sky/widgets/drawer_header.dart';
import 'package:sky/widgets/drawer_item.dart';
import 'package:sky/widgets/floating_action_button.dart';
import 'package:sky/widgets/icon_button.dart';
import 'package:sky/widgets/icon.dart';
import 'package:sky/widgets/material.dart';
import 'package:sky/widgets/navigator.dart';
import 'package:sky/widgets/scaffold.dart';
import 'package:sky/widgets/scrollable_list.dart';
import 'package:sky/widgets/snack_bar.dart';
import 'package:sky/widgets/theme.dart';
import 'package:sky/widgets/tool_bar.dart';
import 'package:sky/widgets/widget.dart';

import 'fitness_types.dart';
import 'measurement.dart';

class MeasurementList extends Component {
  MeasurementList({ Key key, this.measurements, this.onDismissed }) : super(key: key);

  final List<Measurement> measurements;
  final MeasurementHandler onDismissed;

  Widget build() {
    return new Material(
      type: MaterialType.canvas,
      child: new ScrollableList<Measurement>(
        items: measurements,
        itemHeight: MeasurementRow.kHeight,
        itemBuilder: (measurement) => new MeasurementRow(
          measurement: measurement,
          onDismissed: onDismissed
        )
      )
    );
  }
}

class MeasurementRow extends Component {

  MeasurementRow({ Measurement measurement, this.onDismissed }) : this.measurement = measurement, super(key: new Key.stringify(measurement.when));

  final Measurement measurement;
  final MeasurementHandler onDismissed;

  static const double kHeight = 79.0;

  Widget build() {

    List<Widget> children = [
      new Flexible(
        child: new Text(
          measurement.displayWeight,
          style: const TextStyle(textAlign: TextAlign.right)
        )
      ),
      new Flexible(
        child: new Text(
          measurement.displayDate,
          style: Theme.of(this).text.caption.copyWith(textAlign: TextAlign.right)
        )
      )
    ];

    return new Dismissable(
      key: new Key.stringify(measurement.when),
      onDismissed: () => onDismissed(measurement),
      child: new Card(
        child: new Container(
          height: kHeight,
          padding: const EdgeDims.all(8.0),
          child: new Flex(
            children,
            alignItems: FlexAlignItems.baseline,
            textBaseline: DefaultTextStyle.of(this).textBaseline
          )
        )
      )
    );
  }
}

class HomeFragment extends StatefulComponent {

  HomeFragment({ this.navigator, this.userData, this.onMeasurementCreated, this.onMeasurementDeleted });

  Navigator navigator;
  List<Measurement> userData;
  MeasurementHandler onMeasurementCreated;
  MeasurementHandler onMeasurementDeleted;

  FitnessMode _fitnessMode = FitnessMode.measure;

  void initState() {
    // if (debug)
    //   new Timer(new Duration(seconds: 1), dumpState);
    super.initState();
  }

  void syncFields(HomeFragment source) {
    navigator = source.navigator;
    userData = source.userData;
    onMeasurementCreated = source.onMeasurementCreated;
    onMeasurementDeleted = source.onMeasurementDeleted;
  }

  bool _isShowingSnackBar = false;
  bool _isRunning = false;

  void _handleFitnessModeChange(FitnessMode value) {
    setState(() {
      _fitnessMode = value;
    });
  }

  Drawer buildDrawer() {
    if (_drawerStatus == DrawerStatus.inactive)
      return null;
    return new Drawer(
      showing: _drawerShowing,
      level: 3,
      onStatusChanged: _handleDrawerStatusChange,
      navigator: navigator,
      children: [
        new DrawerHeader(children: [new Text('Fitness')]),
        new DrawerItem(
          icon: 'action/assessment',
          onPressed: () => _handleFitnessModeChange(FitnessMode.measure),
          selected: _fitnessMode == FitnessMode.measure,
          children: [new Text('Measure')]),
        new DrawerItem(
          icon: 'maps/directions_run',
          onPressed: () => _handleFitnessModeChange(FitnessMode.run),
          selected: _fitnessMode == FitnessMode.run,
          children: [new Text('Run')]),
        new DrawerDivider(),
        new DrawerItem(
          icon: 'action/settings',
          onPressed: _handleShowSettings,
          children: [new Text('Settings')]),
        new DrawerItem(
          icon: 'action/help',
          children: [new Text('Help & Feedback')])
     ]
    );
  }

  bool _drawerShowing = false;
  DrawerStatus _drawerStatus = DrawerStatus.inactive;

  void _handleOpenDrawer() {
    setState(() {
      _drawerShowing = true;
      _drawerStatus = DrawerStatus.active;
    });
  }

  void _handleDrawerStatusChange(DrawerStatus status) {
    setState(() {
      _drawerStatus = status;
    });
  }

  void _handleShowSettings() {
    navigator.pop();
    navigator.pushNamed('/settings');
  }

  // TODO(jackson): We should be localizing
  String get fitnessModeTitle {
    switch(_fitnessMode) {
      case FitnessMode.measure: return "Measure";
      case FitnessMode.run: return "Run";
    }
  }

  Widget buildToolBar() {
    return new ToolBar(
      left: new IconButton(
        icon: "navigation/menu",
        onPressed: _handleOpenDrawer),
      center: new Text(fitnessModeTitle)
    );
  }

  // TODO(jackson): Pull from file
  Measurement _undoMeasurement;

  void _handleMeasurementDismissed(Measurement measurement) {
    onMeasurementDeleted(measurement);
    setState(() {
      _undoMeasurement = measurement;
      _isShowingSnackBar = true;
    });
  }

  Widget buildBody() {
    TextStyle style = Theme.of(this).text.title;
    switch (_fitnessMode) {
      case FitnessMode.measure:
        if (userData.length > 0)
          return new MeasurementList(
            measurements: userData,
            onDismissed: _handleMeasurementDismissed
          );
        return new Material(
          type: MaterialType.canvas,
          child: new Flex(
            [new Text("No measurements yet.\nAdd a new one!", style: style)],
            justifyContent: FlexJustifyContent.center
          )
        );
      case FitnessMode.run:
        return new Material(
          type: MaterialType.canvas,
          child: new Flex([
            new Text(_isRunning ? "Go go go!" : "Start a new run!", style: style)
          ], justifyContent: FlexJustifyContent.center)
        );
    }
  }

  void _handleUndo() {
    onMeasurementCreated(_undoMeasurement);
    setState(() {
      _undoMeasurement = null;
      _isShowingSnackBar = false;
    });
  }

  Widget buildSnackBar() {
    if (!_isShowingSnackBar)
      return null;
    return new SnackBar(
      content: new Text("Measurement deleted."),
      actions: [new SnackBarAction(label: "UNDO", onPressed: _handleUndo)]
    );
  }

  void _handleRunStarted() {
    setState(() {
      _isRunning = true;
    });
  }

  void _handleRunStopped() {
    setState(() {
      _isRunning = false;
    });
  }

  Widget buildFloatingActionButton() {
    switch (_fitnessMode) {
      case FitnessMode.measure:
        return new FloatingActionButton(
          child: new Icon(type: 'content/add', size: 24),
          onPressed: () => navigator.pushNamed("/measurements/new")
        );
      case FitnessMode.run:
        return new FloatingActionButton(
          child: new Icon(
            type: _isRunning ? 'av/stop' : 'maps/directions_run',
            size: 24
          ),
          onPressed: _isRunning ? _handleRunStopped : _handleRunStarted
        );
    }
  }

  Widget build() {
    return new Scaffold(
      toolbar: buildToolBar(),
      body: buildBody(),
      snackBar: buildSnackBar(),
      floatingActionButton: buildFloatingActionButton(),
      drawer: buildDrawer()
    );
  }
}
