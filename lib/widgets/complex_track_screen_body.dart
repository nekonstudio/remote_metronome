import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../controllers/metronome_settings_controller.dart';
import '../models/section.dart';
import 'metronome_settings_panel.dart';

class ComplexTrackScreenBody extends StatefulWidget {
  final List<Section> trackSections;

  const ComplexTrackScreenBody(this.trackSections);

  @override
  _ComplexTrackScreenBodyState createState() => _ComplexTrackScreenBodyState();
}

class _ComplexTrackScreenBodyState extends State<ComplexTrackScreenBody> {
  MetronomeSettingsController _metronomeSettingsController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('Sekcje utworu'),
            trailing: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 25,
                icon: Icon(
                  Icons.add_circle,
                  size: 35,
                ),
                onPressed: () {
                  _metronomeSettingsController = MetronomeSettingsController();
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) => _SectionForm(
                      controller: _metronomeSettingsController,
                      onFormSubmit: _addSection,
                    ),
                  );
                }),
          ),
          widget.trackSections.isEmpty
              ? Container(
                  color: Color.fromRGBO(36, 36, 36, 1),
                  height: 60,
                  child: Center(
                    child: Text('Brak sekcji'),
                  ),
                )
              : Container(
                  height: (72 * widget.trackSections.length).toDouble(),
                  child: ClipRect(
                    child: ListView.separated(
                      separatorBuilder: (_, __) => Divider(
                        height: 0,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.trackSections.length,
                      itemBuilder: (context, index) {
                        final section = widget.trackSections[index];
                        _metronomeSettingsController =
                            MetronomeSettingsController(initialSettings: section.settings);
                        return _SectionListItem(
                          index: index,
                          section: section,
                          settingsController: _metronomeSettingsController,
                          onSectionEdit: (newSection) => _editSection(index, newSection),
                          onSectionDelete: _deleteSection,
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _addSection(Section section) => setState(() => widget.trackSections.add(section));
  void _editSection(int currentSectionIndex, Section newSection) =>
      setState(() => widget.trackSections[currentSectionIndex] = newSection);
  void _deleteSection(Section section) => setState(() => widget.trackSections.remove(section));
}

class _SectionListItem extends StatelessWidget {
  final int index;
  final Section section;
  final MetronomeSettingsController settingsController;
  final void Function(Section) onSectionEdit;
  final void Function(Section) onSectionDelete;

  const _SectionListItem({
    Key key,
    @required this.index,
    @required this.section,
    @required this.settingsController,
    @required this.onSectionEdit,
    @required this.onSectionDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.2,
      child: Container(
        color: Color.fromRGBO(36, 36, 36, 1),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Text('${index + 1}.'),
          ),
          title: Text(section.title),
          subtitle: Text('${section.settings.tempo} BPM'),
          trailing: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Text(
              'x${section.barsCount}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      secondaryActions: [
        IconSlideAction(
          caption: 'Edytuj',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (_) => _SectionForm(
                      section: section,
                      onFormSubmit: onSectionEdit,
                      controller: settingsController,
                    ));
          },
        ),
        IconSlideAction(
          caption: 'Usuń',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => onSectionDelete(section),
        ),
      ],
    );
  }
}

class _SectionForm extends StatefulWidget {
  final MetronomeSettingsController controller;
  final void Function(Section) onFormSubmit;
  final Section section;

  const _SectionForm({
    Key key,
    @required this.controller,
    @required this.onFormSubmit,
    this.section,
  }) : super(key: key);

  @override
  __SectionFormState createState() => __SectionFormState();
}

class __SectionFormState extends State<_SectionForm> {
  final _formKey = GlobalKey<FormState>();

  String _title;
  int _barsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).viewInsets.bottom + 440,
      child: Column(
        children: [
          Container(
            color: Colors.black26,
            child: ListTile(
              leading: Icon(Icons.playlist_add),
              title: Text(widget.section == null ? 'Dodaj sekcję' : 'Edytuj sekcję'),
            ),
          ),
          MetronomeSettingsPanel(widget.controller),
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    initialValue: widget.section?.title ?? '',
                    decoration: InputDecoration(
                      labelText: 'Nazwa',
                    ),
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _title = value;
                    },
                    validator: (text) => text.isEmpty ? 'To pole nie może być puste' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: widget.section?.barsCount?.toString() ?? '',
                          decoration: InputDecoration(
                            labelText: 'Ilość taktów',
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: false, signed: false),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onSaved: (value) {
                            _barsCount = int.parse(value);
                          },
                          validator: (text) {
                            if (text.isEmpty) {
                              return 'To pole nie może być puste';
                            }
                            if (int.parse(text) <= 0) {
                              return 'To pole musi mieć wartość większą od 0';
                            }

                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 23, left: 20),
                        child: RaisedButton(
                          child: Text(widget.section == null ? 'Dodaj' : 'Zmień'),
                          onPressed: () {
                            _submitForm();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();

      final section = Section(
        title: _title,
        barsCount: _barsCount,
        settings: widget.controller.value,
      );

      widget.onFormSubmit(section);
      Get.back();
    }
  }
}
