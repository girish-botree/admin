import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/utils/responsive.dart';
import 'dashboard_cards.dart';
import 'package:admin/config/app_config.dart' show AppText;

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.bold(
          'Dashboard',
          color: context.theme.colorScheme.onSurface,
          size: 20,
        ),
        backgroundColor: context.theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: context.theme.colorScheme.onSurface,
            ),
            onPressed: () {
              // Refresh dashboard data
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.bold(
                            'Welcome Back, Admin',
                            size: 24,
                            color: context.theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            'Manage your food delivery business efficiently.',
                            size: 16,
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withOpacity(
                            0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.dashboard_customize,
                        color: context.theme.colorScheme.primary,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dashboard cards section
              AppText.semiBold(
                'Quick Actions',
                size: 18,
                color: context.theme.colorScheme.onSurface,
              ),
              const SizedBox(height: 16),

              // Responsive grid layout for cards
              _buildCardsLayout(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsLayout(BuildContext context) {
    // For mobile: display cards in a column
    // For tablet/web: display cards in a grid
    return Responsive(
      mobile: Column(
        children: [
          DashboardCards.buildDeliveryManagementCard(context),
          DashboardCards.buildAddAdminCard(context),
          DashboardCards.buildReportsCard(context),
        ],
      ),
      tablet: Wrap(
        alignment: WrapAlignment.start,
        children: [
          DashboardCards.buildDeliveryManagementCard(context),
          DashboardCards.buildAddAdminCard(context),
          DashboardCards.buildReportsCard(context),
        ],
      ),
      web: Wrap(
        alignment: WrapAlignment.start,
        children: [
          DashboardCards.buildDeliveryManagementCard(context),
          DashboardCards.buildAddAdminCard(context),
          DashboardCards.buildReportsCard(context),
        ],
      ),
    );
  }
}