import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../../../core/database/app_database.dart';

import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/providers/customers_provider.dart';
import '../../../../core/providers/customers_repository_provider.dart';
import '../../../../core/providers/products_provider.dart';
import '../../../../core/providers/sales_repository_provider.dart';
import '../../../../core/providers/selected_customer_provider.dart';

import '../../../../core/printer/thermal_printer_service.dart';
import '../../../../core/printer/thermal_printer_mac_service.dart';

import '../../models/checkout_request.dart';
import '../../models/payment_data.dart';

import 'customer_search_dialog.dart';
import 'payment_dialog.dart';
import 'add_service_dialog.dart';

import 'package:lingo_store/features/customers/presentation/widgets/add_customer_dialog.dart';


class CartPanel extends ConsumerStatefulWidget {

  const CartPanel({
    super.key,
  });


  @override
  ConsumerState<CartPanel> createState() =>
      _CartPanelState();

}



class _CartPanelState extends ConsumerState<CartPanel> {


  double discount = 0;



  @override
  Widget build(BuildContext context) {


    final cart = ref.watch(cartProvider);

    final notifier = ref.read(cartProvider.notifier);

    final selectedCustomer =
        ref.watch(selectedCustomerProvider);



    final total =
        notifier.subtotal - discount;



    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(AppRadius.lg),

        border:
            Border.all(
              color: AppColors.border,
            ),

        boxShadow:
            AppShadows.card,

      ),


      child: Padding(

        padding:
            const EdgeInsets.all(AppSpacing.lg),


        child: Column(

          children: [



            Text(
              "Current Invoice",
              style: AppTextStyles.h3,
            ),



            const SizedBox(height:20),




            // CUSTOMER

            ref.watch(customersProvider).when(

              data: (customers){

                return Column(

                  children: [


                    InkWell(

                      onTap: () async {


                        final customer =
                            await showDialog<Customer>(

                              context: context,

                              builder: (_) =>
                                  const CustomerSearchDialog(),

                            );


                        if(customer != null){

                          ref
                          .read(selectedCustomerProvider.notifier)
                          .state = customer;

                        }


                      },


                      child: InputDecorator(

                        decoration:
                            const InputDecoration(

                              labelText:"Customer",

                              border:
                                  OutlineInputBorder(),

                            ),


                        child: Row(

                          children: [

                            const Icon(
                              Icons.person,
                            ),


                            const SizedBox(
                              width:8,
                            ),


                            Expanded(

                              child: Text(

                                selectedCustomer == null

                                ? "Walk-in Customer"

                                : "${selectedCustomer.name} - ${selectedCustomer.phone ?? ''}",

                              ),

                            ),


                            const Icon(
                              Icons.search,
                            ),


                          ],

                        ),

                      ),

                    ),



                    const SizedBox(height:10),



                    SizedBox(

                      width:double.infinity,


                      child: OutlinedButton.icon(

                        onPressed: () async {


                          final result =
                              await showDialog(

                                context:context,

                                builder:(_)=>
                                  const AddCustomerDialog(),

                              );


                          if(result == null) return;


                          final data =
                              result as Map<String,dynamic>;


                          final repo =
                              ref.read(
                                customersRepositoryProvider,
                              );


                          final id =
                              await repo.insert(

                                CustomersCompanion.insert(

                                  name:
                                      Value(
                                        data["name"].toString(),
                                      ),


                                  phone:
                                      Value(
                                        data["phone"]
                                        .toString()
                                        .isEmpty

                                        ? null

                                        : data["phone"].toString(),

                                      ),

                                ),

                              );


                          ref.invalidate(
                            totalCustomersProvider,
                          );


                          final customer =
                              await repo.getById(id);



                          if(customer != null){

                            ref
                            .read(selectedCustomerProvider.notifier)
                            .state = customer;

                          }


                        },


                        icon:
                            const Icon(
                              Icons.person_add,
                            ),


                        label:
                            const Text(
                              "Add Customer",
                            ),

                      ),

                    ),



                  ],

                );

              },


              loading:()=>
                  const LinearProgressIndicator(),


              error:(e,_) =>
                  Text(
                    e.toString(),
                  ),

            ),




            const SizedBox(height:20),




            // CART ITEMS


            Expanded(

              child:

              cart.isEmpty

              ?

              const Center(
                child:
                    Text(
                      "No items added",
                    ),
              )


              :

              ListView.separated(

                itemCount:
                    cart.length,


                separatorBuilder:
                    (_,_) =>
                    const Divider(),



                itemBuilder:(context,index){


                  final item =
                      cart[index];


                  return Row(

                    children: [


                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,


                          children: [


                            Text(
                              item.name,
                              style:
                                  AppTextStyles.bodyMedium,
                            ),


                            Text(
                              "${item.price} EGP",
                            ),


                          ],

                        ),

                      ),



                      IconButton(

                        onPressed:
                            ()=>notifier.decrease(index),


                        icon:
                            const Icon(
                              Icons.remove_circle_outline,
                            ),

                      ),



                      Text(
                        item.quantity.toString(),
                      ),



                      IconButton(

                        onPressed:
                            ()=>notifier.increase(index),


                        icon:
                            const Icon(
                              Icons.add_circle_outline,
                            ),

                      ),



                      IconButton(

                        onPressed:
                            ()=>notifier.remove(index),


                        icon:
                            const Icon(
                              Icons.delete_outline,
                              color:Colors.red,
                            ),

                      ),


                    ],

                  );


                },

              ),

            ),





            const Divider(),




            _summaryRow(
              "Items",
              notifier.itemsCount.toDouble(),
              isCount:true,
            ),



            _summaryRow(
              "Subtotal",
              notifier.subtotal,
            ),



            TextField(

              keyboardType:
                  TextInputType.number,


              decoration:
                  const InputDecoration(

                    labelText:
                        "Discount (EGP)",

                    border:
                        OutlineInputBorder(),

                  ),



              onChanged:(value){


                setState(() {

                  discount =
                      double.tryParse(value) ?? 0;

                });


              },

            ),




            const SizedBox(height:10),



            _summaryRow(
              "Discount",
              discount,
            ),



            _summaryRow(
              "Total",
              total,
              bold:true,
            ),




            const SizedBox(height:15),




            SizedBox(

              width:double.infinity,

              height:50,


              child: FilledButton.icon(

                onPressed:

                cart.isEmpty

                ? null


                :

                () async {


                  final payment =
                      await showDialog<PaymentData>(

                        context:context,

                        builder:(_)=>
                            PaymentDialog(
                              total:total,
                            ),

                      );



                  if(payment == null)
                    return;



                  try{


                    final repo =
                        ref.read(
                          salesRepositoryProvider,
                        );



                    final request =
                        CheckoutRequest(

                          items:cart,


                          userId:1,


                          customerId:
                              selectedCustomer?.id,


                          discount:
                              discount,


                          tax:0,


                          payments:[
                            payment,
                          ],

                        );



                    final saleId =
                        await repo.checkout(
                          request,
                        );



                    final sale =
                        await repo.getSaleById(
                          saleId,
                        );



                    final items =
                        await repo.getSaleItems(
                          saleId,
                        );



                    if(sale != null){

                      unawaited(

                        Future(() async{


                          try{


                            if(Platform.isWindows){

                              await ThermalPrinterService.printInvoice(
                                sale:sale,
                                items:items,
                              );


                            }


                            else if(Platform.isMacOS){


                              await ThermalPrinterMacService.printInvoice(
                                sale:sale,
                                items:items,
                              );


                            }


                          }

                          catch(e){

                            debugPrint(
                              "Printer Error: $e",
                            );

                          }


                        }),


                      );


                    }



                    ref
                    .read(cartProvider.notifier)
                    .clear();



                    if(context.mounted){

                      ScaffoldMessenger.of(context)
                      .showSnackBar(

                        const SnackBar(

                          content:
                              Text(
                                "Sale completed",
                              ),

                        ),

                      );

                    }



                  }


                  catch(e){


                    if(context.mounted){

                      ScaffoldMessenger.of(context)
                      .showSnackBar(

                        SnackBar(
                          content:
                              Text(
                                "Error: $e",
                              ),
                        ),

                      );

                    }


                  }



                },


                icon:
                    const Icon(
                      Icons.payments_outlined,
                    ),


                label:
                    const Text(
                      "Pay",
                    ),


              ),

            ),


          ],

        ),

      ),

    );

  }




  Widget _summaryRow(
    String title,
    double value, {

    bool bold=false,

    bool isCount=false,

  }){


    final style =
        bold

        ?

        const TextStyle(
          fontSize:18,
          fontWeight:FontWeight.bold,
        )


        :

        const TextStyle(
          fontSize:15,
        );



    return Padding(

      padding:
          const EdgeInsets.symmetric(
            vertical:6,
          ),


      child: Row(

        children: [


          Text(
            title,
            style:style,
          ),


          const Spacer(),



          Text(

            isCount

            ?

            value.toInt().toString()

            :

            "${value.toStringAsFixed(2)} EGP",


            style:style,

          ),


        ],

      ),

    );

  }


}
