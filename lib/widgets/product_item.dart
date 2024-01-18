import 'package:flutter/material.dart';
import '../providers/auth.dart';
import '../providers/product.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: IconButton(
            icon: product.isFavorite
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border),
            onPressed: () async {
              try {
                await product.toggleFavoriteStatus(auth.token, auth.userId);
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Set favorite failed!'),
                  ),
                );
              }
            },
            color: Theme.of(context).hintColor,
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "add item to cart",
                ),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    }),
              ));
            },
            color: Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}
