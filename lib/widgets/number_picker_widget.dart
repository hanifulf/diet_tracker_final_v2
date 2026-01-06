import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NumberPickerWidget extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final String suffix;
  final Function(int) onChanged;
  final double? step;

  const NumberPickerWidget({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.suffix,
    required this.onChanged,
    this.step,
  });

  @override
  State<NumberPickerWidget> createState() => _NumberPickerWidgetState();
}

class _NumberPickerWidgetState extends State<NumberPickerWidget> {
  late ScrollController _scrollController;
  late int _selectedValue;
  final double _itemHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _scrollController = ScrollController(
      initialScrollOffset: (_selectedValue - widget.minValue) * _itemHeight,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollUpdate() {
    final offset = _scrollController.offset;
    final index = (offset / _itemHeight).round();
    final newValue = (widget.minValue + index).clamp(widget.minValue, widget.maxValue);
    
    if (newValue != _selectedValue) {
      setState(() {
        _selectedValue = newValue;
      });
      widget.onChanged(_selectedValue);
    }
  }

  void _snapToNearestValue() {
    final offset = _scrollController.offset;
    final index = (offset / _itemHeight).round();
    final targetOffset = index * _itemHeight;
    
    _scrollController.animateTo(
      targetOffset,
      duration: AppTheme.shortAnimation,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: AppTheme.cardDecoration,
      child: Stack(
        children: [
          // Selection indicator
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Container(
              height: _itemHeight,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: AppTheme.primaryGreen,
                  width: 2,
                ),
              ),
            ),
          ),
          
          // Number list
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                _onScrollUpdate();
              } else if (scrollNotification is ScrollEndNotification) {
                _snapToNearestValue();
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              itemExtent: _itemHeight,
              padding: const EdgeInsets.symmetric(vertical: 120),
              itemCount: widget.maxValue - widget.minValue + 1,
              itemBuilder: (context, index) {
                final value = widget.minValue + index;
                final isSelected = value == _selectedValue;
                
                return Container(
                  height: _itemHeight,
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: AppTheme.shortAnimation,
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 20,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? AppTheme.primaryGreen 
                          : AppTheme.textSecondary,
                    ),
                    child: Text('$value ${widget.suffix}'),
                  ),
                );
              },
            ),
          ),
          
          // Fade gradients at top and bottom
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cardBackground,
                    AppTheme.cardBackground.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.cardBackground,
                    AppTheme.cardBackground.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

