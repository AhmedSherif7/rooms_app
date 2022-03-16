import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../shared/components/custom_switch.dart';
import '../../shared/components/custom_text_field.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/helper_functions.dart';
import '../../shared/resources/color_manager.dart';
import '../../shared/resources/values_manager.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime _dateTime = DateTime.now();
  bool _roomType = false;

  @override
  void initState() {
    AppCubit.get(context).invitedSpeakers.clear();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AppSpeakerAlreadyInvitedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Speaker already invited',
                style: TextStyle(
                  color: ColorManager.black,
                ),
              ),
              backgroundColor: ColorManager.warningAccent,
            ),
          );
        }
        if (state is AppUserNotFoundState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user found with this phone'),
              backgroundColor: ColorManager.error,
            ),
          );
        }
        if (state is AppCreateRoomSuccessState) {
          Navigator.pop(context, 'Room Created Successfully');
        }
      },
      builder: (context, state) {
        var cubit = AppCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Create your Room',
            ),
          ),
          body: SafeArea(
            child: ConditionalBuilder(
              condition: state is! AppCreateRoomLoadingState,
              builder: (context) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.p16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            controller: _titleController,
                            labelText: 'Title',
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'title is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: AppSize.s30,
                          ),
                          CustomTextField(
                            keyboardType: TextInputType.text,
                            controller: _categoryController,
                            labelText: 'Category',
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'category is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: AppSize.s20,
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ColorManager.blueAccent,
                              child: cubit.invitedSpeakers.isEmpty
                                  ? const Icon(
                                      Icons.mic,
                                      color: ColorManager.white,
                                    )
                                  : Text('${cubit.invitedSpeakers.length}'),
                            ),
                            title: Text(
                              'Add Speakers',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            subtitle: const Text('Optional'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (await FlutterContacts.requestPermission()) {
                                  var contact =
                                      await FlutterContacts.openExternalPick();
                                  if (contact != null) {
                                    var phone =
                                        contact.phones.single.normalizedNumber;
                                    cubit.inviteSpeaker(phone);
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            height: AppSize.s10,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: cubit.invitedSpeakers.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(Icons.person),
                                title:
                                    Text(cubit.invitedSpeakers[index]['name']!),
                                subtitle: Text(
                                    cubit.invitedSpeakers[index]['phone']!),
                                trailing: IconButton(
                                  onPressed: () {
                                    cubit.unInviteSpeaker(index);
                                  },
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: ColorManager.error,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: AppSize.s20,
                          ),
                          Text(
                            'Select Date and Time below',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          const SizedBox(
                            height: AppSize.s10,
                          ),
                          SizedBox(
                            height: AppSize.s180,
                            child: CupertinoDatePicker(
                              backgroundColor: cubit.isDarkMode
                                  ? ColorManager.lightGrey
                                  : ColorManager.lightBackground,
                              minimumDate: DateTime.now(),
                              onDateTimeChanged: (dateTime) {
                                _dateTime = dateTime;
                              },
                              initialDateTime: DateTime.now(),
                            ),
                          ),
                          const SizedBox(
                            height: AppSize.s10,
                          ),
                          CustomSwitch(
                            enabledText: 'Public',
                            disabledText: 'Private',
                            activeIcon: Icons.public,
                            inActiveIcon: Icons.lock,
                            activeColor: ColorManager.lightGrey,
                            inActiveColor: ColorManager.lightGrey,
                            value: _roomType,
                            onToggle: (bool value) {
                              setState(() {
                                _roomType = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: AppSize.s20,
                          ),
                          SizedBox(
                            width: AppSize.deviceWidth,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_dateTime.isAfter(DateTime.now())) {
                                    cubit.createRoom(
                                      _titleController.text.trim(),
                                      _categoryController.text.trim(),
                                      _dateTime,
                                      _roomType,
                                    );
                                  } else {
                                    showToast(
                                      message: 'Date has passed',
                                      state: States.error,
                                    );
                                  }
                                }
                              },
                              child: const Text('CREATE'),
                            ),
                          ),
                          const SizedBox(
                            height: AppSize.s20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              fallback: (context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
