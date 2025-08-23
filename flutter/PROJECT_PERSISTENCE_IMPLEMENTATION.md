# Project Persistence Implementation

## Overview

This document outlines the implementation of persistent project ordering in the Packaroo Flutter application. The feature ensures that the order of projects in the project list is maintained across application sessions, similar to how build statuses and logs are persisted.

## Changes Made

### 1. PackarooProject Model Updates

**File:** `lib/models/packaroo_project.dart`

- **Added `sortOrder` field**: New `@HiveField(27) late int sortOrder` to track project order
- **Updated constructor**: Added optional `sortOrder` parameter with default timestamp-based value
- **Updated copyWith method**: Added `sortOrder` parameter to allow updating sort order
- **Updated JSON serialization**: Added `sortOrder` to both `toJson()` and `fromJson()` methods

### 2. ProjectProvider State Management

**File:** `lib/providers/project_provider.dart`

- **Modified `loadProjects()`**: Changed sorting from `lastModified` descending to `sortOrder` ascending
- **Updated `createProject()`**: Sets appropriate `sortOrder` for new projects (max + 1)
- **Enhanced `duplicateProject()`**: Calculates insertion point for duplicated projects
- **Added reordering methods**:
  - `reorderProjects(int oldIndex, int newIndex)`: Handle drag-and-drop reordering
  - `moveProjectToPosition(String projectId, int newPosition)`: Move project to specific position
  - `_updateSortOrders()`: Updates sort orders for all projects based on list position
  - `resetProjectOrder()`: Reset order to creation date order

### 3. Storage Service Migration

**File:** `lib/services/storage_service.dart`

- **Added migration logic**: `_migrateProjectsSortOrder()` method to handle existing projects
- **Updated initialization**: Calls migration method during storage initialization
- **Backward compatibility**: Ensures existing projects get appropriate sort order values

### 4. UI Enhancements

**File:** `lib/widgets/project_list.dart`

- **Replaced ListView with ReorderableListView**: Enables drag-and-drop when not searching
- **Added visual drag handle**: Shows drag handle icon for reorderable items
- **Enhanced context menu**: Added "Move to Top" and "Move to Bottom" options
- **Added informational text**: Hints about drag-and-drop functionality
- **Separated search and normal views**: Different rendering based on search state

### 5. Code Generation

- **Regenerated Hive adapters**: Used `flutter packages pub run build_runner build --delete-conflicting-outputs`
- **Updated type annotations**: Ensured new field is properly serialized

## Features Implemented

### Core Functionality

1. **Persistent Ordering**: Project order is saved to Hive storage and restored on app restart
2. **Drag-and-Drop Reordering**: Users can drag projects to reorder them in the list
3. **Context Menu Actions**: "Move to Top" and "Move to Bottom" options
4. **Search Compatibility**: Ordering features are hidden during search to avoid confusion
5. **Migration Support**: Existing projects are automatically migrated with appropriate sort orders

### User Experience

1. **Visual Feedback**: Drag handle icons indicate draggable items
2. **Informational Hints**: Help text explains the drag-and-drop functionality
3. **Snackbar Confirmations**: User feedback for move operations
4. **Seamless Integration**: Feature works alongside existing project management

## Technical Details

### Sort Order Algorithm

- **New projects**: Get `max(existing_sort_orders) + 1`
- **Duplicated projects**: Insert between original and next project using `(a + b) / 2`
- **Reordered projects**: Use increments of 1000 to allow future insertions
- **Migrated projects**: Use creation timestamp as initial sort order

### Data Persistence

- **Storage**: Hive database with automatic persistence
- **Migration**: Seamless upgrade for existing users
- **Backup Compatibility**: Sort order included in export/import operations

### Performance Considerations

- **Lazy Loading**: Projects loaded once and cached in memory
- **Efficient Updates**: Only modified projects are saved during reordering
- **Batch Operations**: Sort order updates happen in batches for better performance

## Usage Instructions

### For Users

1. **View Projects**: Projects are displayed in saved order by default
2. **Reorder Projects**: 
   - Drag and drop projects to reorder them
   - Or use the context menu (⋮) for "Move to Top"/"Move to Bottom"
3. **Search Projects**: Type in search box - ordering features are temporarily disabled
4. **Persistent Order**: Close and reopen the app - order is maintained

### For Developers

1. **Adding New Projects**: Use `ProjectProvider.createProject()` - sort order is automatic
2. **Modifying Order**: Use `ProjectProvider.reorderProjects()` or `moveProjectToPosition()`
3. **Reset Order**: Use `ProjectProvider.resetProjectOrder()` to reset to creation date order
4. **Custom Ordering**: Modify `sortOrder` field in project and call `updateProject()`

## Migration Considerations

- **Backward Compatibility**: Existing projects without `sortOrder` are automatically migrated
- **Default Values**: New installations start with creation-date-based ordering
- **No Data Loss**: All existing project data is preserved during migration

## Future Enhancements

1. **Folder/Category Organization**: Group projects into folders
2. **Custom Sorting Options**: Allow sorting by name, date, type, etc.
3. **Bulk Operations**: Select multiple projects for batch reordering
4. **Import/Export Order**: Save and restore custom project arrangements

## Testing

To test the implementation:

1. **Create Multiple Projects**: Add several projects to see ordering
2. **Reorder Projects**: Use drag-and-drop and context menu options
3. **Restart Application**: Verify order is preserved after app restart
4. **Search and Reorder**: Test that search disables reordering features
5. **Migration Test**: Test with existing project data to ensure smooth migration

## Conclusion

The project persistence implementation provides a seamless user experience for managing project order while maintaining backward compatibility and following established patterns in the application. The feature integrates naturally with the existing UI and provides both drag-and-drop and menu-based reordering options.
