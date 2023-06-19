import 'package:flutter/material.dart';
import 'package:app/model/Category.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CategoryListTile extends StatelessWidget {
  final Category category;
  final Function() onCategoryDelete;
  final Function() onCategorySelect;

  const CategoryListTile({
    Key? key,
    required this.category,
    required this.onCategoryDelete,
    required this.onCategorySelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(category.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (context) {
              onCategoryDelete();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Category: ${category.title} deleted')));
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            key: Key("delCatBtn_${category.id}"),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.folder),
        title: Text(category.title),
        trailing: const Icon(Icons.navigate_next),
        onTap: onCategorySelect,
      ),
    );
  }
}
