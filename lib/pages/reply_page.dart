import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReplyPage extends StatefulWidget {
  const ReplyPage({Key? key}) : super(key: key);

  @override
  _ReplyPageState createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Compose",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.only(left: 18),
              child: const Icon(
                Icons.attachment,
                color: Colors.black,
                size: 22,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.only(left: 15, right: 10),
              child: const Icon(
                Icons.more_vert,
                color: Colors.black,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: size.width * 0.9,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 10),
                      child: const Text(
                        "To",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  color: Colors.grey.shade400,
                  height: .5,
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  height: 100,
                  child: const Text('Text Message Here'),
                ),
                Container(
                  color: Colors.grey.shade400,
                  height: .5,
                ),
                const Expanded(
                  child: TextField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    expands: true,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Compose message"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
